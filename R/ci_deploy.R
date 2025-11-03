#' (INTERNAL) Build and deploy the site with continous integration
#'
#' A platform-agnostic method of deploying a lesson website and cached content.
#' This function takes advantage of git worktrees to render and push content to
#' orphan branches, which can be used to host the lesson website. **This
#' function assumes that you are in a git clone from a remote and have write
#' access to that remote**.
#'
#' @param path path to the lesson
#' @param md_branch the branch name that contains the markdown outputs
#' @param site_branch the branch name that contains the full HTML site
#' @param remote the name of the git remote to which you should deploy.
#' @param reset if `TRUE`, the markdown cache is cleared before rebuilding,
#'   this defaults to `FALSE` meaning the markdown cache will be provisioned
#'   and used.
#' @param skip_manage_deps if `TRUE`, dependency management will NOT be processed.
#'   This defaults to `FALSE`. Set this to TRUE to force dependency management
#'   to be handled in the separate package cache update and apply steps in the
#'   CI workflow, and therefore can be skipped.
#' @return Nothing, invisibly. This is used for it's side-effect
#'
#' @details
#'
#' `ci_deploy()` does the same thing as [build_lesson()], except instead of
#' storing the outputs under the `site/` folder, it pushes the outputs to
#' remote orphan branches (determined by the `md_branch` and `site_branch`
#' arguments). These branches are used as the cache and the website,
#' respectively. If these branches do not exist, they will be created.
#'
#' ## Requirements
#'
#' This function can only run in a non-interactive fashion. If you try to run
#' it interactively, you will get an error message. It assumes that the
#' following are true:
#'
#'  - it is running in a script or automated workflow
#'  - it is running in a clone of a git repository
#'  - the remote exists and is writable
#'
#' Unexpected consequences can arise from violating these assumptions.
#'
#' ## Workflow
#'
#' This function has a similar two-step workflow as [build_lesson()], with a
#' few extra steps to ensure that the git branches are set up correctly. Below
#' are the steps with elements common to [build_lesson()] annotated with `*`
#'
#' 1. check that a git user and email is registered
#' 2. `*` Validate the lesson and generate global variables with [validate_lesson()]
#' 3. provision, build, and deploy markdown branch with [ci_build_markdown()]
#'    i. provision markdown branch with [git_worktree_setup()]
#'    ii. `*` build the markdown source documents with [build_markdown()]
#'    iii. commit and push the git worktree to the remote branch with [github_worktree_commit()]
#' 4. provision, build, and deploy site branch with [ci_build_site()]
#'    i. provision site branch with [git_worktree_setup()]
#'    ii. `*` build the site HTML documents with [build_site()]
#'    iii. commit and push the git worktree to the remote branch with [github_worktree_commit()]
#'    iv. remove the git worktree with [github_worktree_remove()]
#' 5. remove markdown git worktree with [github_worktree_remove()]
#'
#'
#' @note this function is not for interactive use. It requires git to be
#'   installed on your machine and will destroy anything you have in the
#'   `site/` folder. For R-based lessons it _will_ rebuild all components if the
#'   lockfile has changed.
#'
#' @keywords internal
#' @rdname ci_deploy
#' @examplesIf sandpaper:::example_can_run()
#' # For this example, we are setting up a temporary repository with a local
#' # remote called `sandpaper-local`. This demonstrates how `ci_deploy()`
#' # modifies the remote, but there are setup and teardown steps to run.
#' # The actual example is highlighted below under the DEPLOY comment.
#'
#' # SETUP -------------------------------------------------------------------
#' snd <- asNamespace("sandpaper")
#' tik <- Sys.time()
#' cli::cli_h1("Set up")
#' cli::cli_h2("Create Lesson")
#' restore_fixture <- snd$create_test_lesson()
#' res <- getOption("sandpaper.test_fixture")
#' cli::cli_h2("Create Remote")
#' rmt <- fs::file_temp(pattern = "REMOTE-")
#' snd$setup_local_remote(repo = res, remote = rmt, verbose = FALSE)
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#'
#' # reporting -----
#' # The repository should only have one branch and the remote should be in
#' # sync with the local.
#' cli::cli_h2("Local status")
#' gert::git_branch_list(repo = res)[c('name', 'commit', 'updated')]
#' cli::cli_h2("First episode status")
#' gert::git_stat_files("episodes/introduction.Rmd", repo = res)
#' gert::git_stat_files("episodes/introduction.Rmd", repo = rmt)
#'
#' # DEPLOY ------------------------------------------------------------------
#' tik <- Sys.time()
#' cli::cli_h1("deploy to remote")
#' sandpaper:::ci_deploy(path = res, remote = "sandpaper-local")
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#'
#' # reporting -----
#' # The repository and remote should both have three branches
#' cli::cli_h2("Local status")
#' gert::git_branch_list(repo = res)[c('name', 'commit', 'updated')]
#'
#' # An indicator this worked: the first episode should be represented as
#' # different files across the branches:
#' # - main: Rmd
#' # - md-outputs: md
#' # - gh-pages: html
#' cli::cli_h2("First episode status")
#' gert::git_stat_files("episodes/introduction.Rmd", repo = rmt)
#' cli::cli_h3("rendered markdown")
#' gert::git_stat_files("introduction.md", repo = rmt, ref = "md-outputs")
#' cli::cli_h3("html file")
#' gert::git_stat_files("introduction.html", repo = rmt, ref = "gh-pages")
#'
#' # CLEAN -------------------------------------------------------------------
#' tik <- Sys.time()
#' cli::cli_h1("Clean Up")
#' snd$remove_local_remote(repo = res)
#' snd$reset_git_user(res)
#' # remove the test fixture and report
#' tryCatch(fs::dir_delete(res), error = function() FALSE)
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
ci_deploy <- function(path = ".", md_branch = "md-outputs", site_branch = "gh-pages", remote = "origin", reset = FALSE, skip_manage_deps = FALSE) {

  if (interactive() && is.null(getOption('sandpaper.test_fixture'))) {
    stop("This function is for use on continuous integration only", call. = FALSE)
  }

  # Enforce git user exists
  check_git_user(path, name = "GitHub Actions", email = "actions@github.com")

  validate_lesson(path)

  # Step 1: build markdown source files
  del_md <- ci_build_markdown(path, branch = md_branch, remote = remote,
    reset = reset, skip_manage_deps = skip_manage_deps)
  # NOTE: we delete the markdown worktree at the end because we need it for the
  # site to build from the markdown files.
  on.exit(eval(del_md), add = TRUE)

  # Step 2: build the site from the source files
  ci_build_site(path, branch = site_branch, md = md_branch, remote = remote,
    reset = reset)

  invisible()
}
