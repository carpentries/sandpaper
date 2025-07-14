has_git <- function() {
  Sys.which("git") != ""
}

# Shamelessly stolen from `{pkgdown}`, originally authored by Hadley Wickam
git <- function (..., echo_cmd = TRUE, echo = TRUE, error_on_status = TRUE) {
  if (!has_git()) stop(cli::format_error("{.pkg git} is not installed"), call. = FALSE)
  callr::run("git", c(...), echo_cmd = echo_cmd, echo = echo,
    error_on_status = error_on_status)
}

# check if a remote branch exists
# originally authored by Hadley Wickham
git_has_remote_branch <- function (remote, branch) {
  git(
    "ls-remote", "--quiet", "--exit-code", remote, branch,
    echo = FALSE, echo_cmd = FALSE, error_on_status = FALSE
    )$status == 0
}

git_fetch_one_branch <- function(remote, branch, repo = ".") {
  # NOTE: We only want to fetch ONE branch and ONE branch, only. We apparently
  # cannot do this by specifying a refspec for fetch, but we _can_ temporarily
  # modify the refspec for for the repo.
  # https://stackoverflow.com/a/62264058/2752888
  git("remote", "set-branches", remote, branch)
  on.exit({
    # https://stackoverflow.com/a/47726250/2752888
    git("remote", "set-branches", remote, "*")
  })
  git("fetch", remote, branch)
}

git_clean_everything <- function(repo = ".") {
  withr::with_dir(repo, {
    tryCatch(git("rm", "-rf", "--quiet", "."), error = function(e) NULL)
  })
}


#
# Modified from pkgdown::deploy_to_branch() by Hadley Wickham

#' Setup a git worktree for concurrent manipulation of a separate branch
#'
#' @param path path to the repository
#' @param dest_dir path to the destination directory to contain the work tree
#' @param branch the branch associated with the work tree (default: gh-pages)
#' @param remote the remote name (default: origin)
#' @param throwaway if `TRUE`, the worktree created is in a detached HEAD state
#'   from from the remote branch and will not create a new branch in your
#'   repository. Defaults to `FALSE`, which will create the branch from upstream.
#' @return an [expression()] that calls `git worktree remove` on the worktree
#'   when evaluated.
#' @details
#'
#' This function is used in continuous integration settings where we want to
#' push derived outputs to non-main branches in our repository. We use this to
#' populate the markdown and HTML outputs from the lesson so that we don't have
#' to rebuild the lesson from scratch every time.
#'
#' The logic behind this looks like
#'
#' ```
#' worktree setup
#' [IF BRANCH DOES NOT EXIST]
#'   git checkout --orphan <branch>
#'   git rm -rf --quiet .
#'   git commit --allow-empty -m
#'   git push remote HEAD:<branch>
#'   git checkout -
#' git fetch <remote> +refs/heads/<branch>:refs/remotes/<remote>/<branch>
#' git worktree add --track -B <branch> /path/to/dir <remote>/<branch>
#' ```
#'
#' @note `git_worktree_setup()` has been modified from the logic in
#' [pkgdown::deploy_to_branch()], by Hadley Wickham.
#'
#' @keywords internal
#' @rdname git_worktree
#' @examplesIf sandpaper:::example_can_run()
#' # Use Worktrees to deploy a lesson -----------------------------------------
#' # This example is a bit inovlved, but it is effectively what we do inside of
#' # the `ci_deploy()` function (after setting up the lesson).
#' #
#' # The setup phase will create a new lesson and a corresponding remote (self
#' # contained, no GitHub authentication required).
#' #
#' # The worktrees will be created for both the markdown and HTML outputs on the
#' # branches "md-outputs" and "gh-pages", respectively.
#' #
#' # After the worktrees are created, we will build the lesson into the
#' # worktrees and display the output of `git_status()` for each of the three
#' # branches: "main", "md-outputs", and "gh-pages"
#' #
#' # During the clean up phase, the output of `git_worktree_setup()` is
#' # evaluated
#' tik <- Sys.time()
#' cli::cli_h1("Set up")
#' cli::cli_h2("Create Lesson")
#' restore_fixture <- sandpaper:::create_test_lesson()
#' res <- getOption("sandpaper.test_fixture")
#' sandpaper:::check_git_user(res)
#' cli::cli_h2("Create Remote")
#' rmt <- fs::file_temp(pattern = "REMOTE-")
#' sandpaper:::setup_local_remote(repo = res, remote = rmt, verbose = FALSE)
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#' tik <- Sys.time()
#' cli::cli_h2("Create Worktrees")
#' db <- sandpaper:::git_worktree_setup(res, fs::path(res, "site", "built"),
#'   branch = "md-outputs", remote = "sandpaper-local"
#' )
#' ds <- sandpaper:::git_worktree_setup(res, fs::path(res, "site", "docs"),
#'   branch = "gh-pages", remote = "sandpaper-local"
#' )
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#' tik <- Sys.time()
#' cli::cli_h1("Build Lesson into worktrees")
#' build_lesson(res, quiet = TRUE, preview = FALSE)
#' cli::cli_h2("git status: {gert::git_branch(repo = res)}")
#' print(gert::git_status(repo = res))
#' cli::cli_h2('git status: {gert::git_branch(repo = fs::path(res, "site", "built"))}')
#' print(gert::git_status(repo = fs::path(res, "site", "built")))
#' cli::cli_h2('git status: {gert::git_branch(repo = fs::path(res, "site", "docs"))}')
#' print(gert::git_status(repo = fs::path(res, "site", "docs")))
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#' tik <- Sys.time()
#' cli::cli_h1("Clean Up")
#' cli::cli_alert_info("object db is an expression that evaluates to {.code {db}}")
#' eval(db)
#' cli::cli_alert_info("object ds is an expression that evaluates to {.code {ds}}")
#' eval(ds)
#' sandpaper:::remove_local_remote(repo = res)
#' sandpaper:::reset_git_user(res)
#' # remove the test fixture and report
#' tryCatch(fs::dir_delete(res), error = function() FALSE)
#' tok <- Sys.time()
#' cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
git_worktree_setup <- function (path = ".", dest_dir, branch = "gh-pages", remote = "origin", throwaway = FALSE) {

  if (!has_git() || !requireNamespace("withr", quietly = TRUE)) {
    stop(cli::format_error("{.fn git_worktree_setup} requires {.pkg git} and {.pkg withr}"), call. = FALSE)
  }
  withr::with_dir(path, {
    no_branch <- !git_has_remote_branch(remote, branch)
    # create the branch if it doesn't exist
    if (no_branch) {
      ci_group("Create New Branch")
      old_branch <- gert::git_branch(repo = path)
      git("checkout", "--orphan", branch)
      git("rm", "-rf", "--quiet", ".")
      git("commit", "--allow-empty", "-m",
        sprintf("Initializing %s branch", branch)
      )
      git("push", remote, paste0("HEAD:", branch))
      git("checkout", old_branch)
      cli::cat_line("::endgroup::")
    }
    ci_group(glue::glue("Fetch {remote}/{branch}"))
    git_fetch_one_branch(remote, branch, repo = path)
    cli::cat_line("::endgroup::")

    ci_group(glue::glue("Add worktree for {remote}/{branch} in site/{fs::path_file(dest_dir)}"))
    github_worktree_add(dest_dir, remote, branch, throwaway)
    cli::cat_line("::endgroup::")
  })
  # This allows me to evaluate this expression at the top of the calling
  # function.
  parse(text = glue::glue("sandpaper:::github_worktree_remove('{dest_dir}', '{path}')"))
}


# Add a branch to a folder as a worktree
# originally authored by Hadley Wickham
github_worktree_add <- function (dir, remote, branch, throwaway = FALSE) {
  if (throwaway) {
    the_tree <- c("--detach", dir)
  } else {
    the_tree <- c("--track", "-B", branch, dir)
  }
  git("worktree", "add", the_tree, paste0(remote, "/", branch))
}

#' @rdname git_worktree
#' @note
#' `github_worktree_commit()`: Modified from `pkgdown:::github_push` by Hadley
#' Wickham
github_worktree_commit <- function (dir, commit_message, remote, branch) {
  force(commit_message)
  if (requireNamespace("cli", quietly = TRUE))
    cli::rule("Committing", line = "c")
  # ZNK: add explicit check for withr
  if (!requireNamespace("withr", quietly = TRUE))
    stop("withr must be installed")
  withr::with_dir(dir, {
    # ZNK: Change to gert::git_add(); only commit if we have something to add
    added <- gert::git_add(".", repo = dir)
    if (nrow(added) == 0) {
      message(glue::glue("nothing to commit on {branch}!"))
      return(NULL)
    }
    git("commit", "--allow-empty", "-m", commit_message)
    cli::rule("Deploying", line = 1)
    git("remote", "-v")
    git("push", "--force", remote, paste0("HEAD:", branch))
  })
}

#' @rdname git_worktree
#' @note
#' `github_worktree_remove()`: Modified from `pkgdown:::github_worktree_remove`
#' by Hadley Wickham
github_worktree_remove <- function (dir, home = NULL) {
  if (requireNamespace("cli", quietly = TRUE))
    cli::rule("Removing worktree", line = "-")
  # ZNK: add --force
  if (is.null(home)) home <- root_path(dir)
  if (requireNamespace("withr", quietly = TRUE)) {
    withr::with_dir(home, git("worktree", "remove", "--force", dir))
  }
}

# Generate a commit message that includes information about the source of the
# build.
message_source <- function(commit_message = "", source_branch = "main", dir = ".") {
  log <- gert::git_log(ref = source_branch, max = 1L, repo = dir)
  paste0(commit_message,
    "\n",
    "\nAuto-generated via `{sandpaper}`\n",
    "Source  : ", log$commit, "\n",
    "Branch  : ", source_branch, "\n",
    "Author  : ", log$author, "\n",
    "Time    : ", UTC_timestamp(log$time), "\n",
    "Message : ", log$message
  )
}

# NOTE: I believe this should work, but for now, I think the variables should be
# explicitly named in the YAML:
#
# - name: "Generate Artifacts"
#   id: generate-artifacts
#   run: |
#     sandpaper:::ci_bundle_pr_artifacts(
#       repo         = '${{ github.repository }}',
#       pr_number    = '${{ github.event.number }}',
#       path_md      = '${{ env.MD }}',
#       path_pr      = '${{ env.PR }}',
#       path_archive = '${{ env.CHIVE }}',
#       branch       = "md-outputs"
#     )
#   shell: Rscript {0}
ci_bundle_pr_artifacts <- function(repo, pr_number,
  path_md, path_archive, path_pr,
  branch = "md-outputs") {
  if (!fs::dir_exists(path_archive)) fs::dir_create(path_archive)
  if (!fs::dir_exists(path_pr)) fs::dir_create(path_pr)
  writeLines(pr_number, fs::path(path_pr, "NR"))
  if (!requireNamespace("withr", quietly = TRUE))
    stop("withr must be installed")
  withr::with_dir(path_md, {
    git("add", "-A", ".", echo_cmd = FALSE, echo = FALSE)
    difflist <- git("diff", "--staged", "--compact-summary",
      echo = FALSE, echo_cmd = FALSE)$stdout
    github_url  <- glue::glue("https://github.com/{repo}/compare/")
    reality <- glue::glue("{github_url}{branch}")
    possibility <- glue::glue("{branch}-PR-{pr_number}")
    # Comparing commit-ish chunks on GitHub can use either two dot or three dot
    #
    # Three dot: compare changes that happened _in that instant_
    # Two dot: compare the changes between the branches as they exist today.
    #
    # https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-comparing-branches-in-pull-requests#three-dot-and-two-dot-git-diff-comparisons
    #
    # I was using the two-dot method because that's the only thing I learned,
    # but it can be really overwhelming if there are rapid changes. This way,
    # only the relevant changes are shown (unless there is a conflict).
    copy_template("pr_diff", path_archive, "diff.md",
      values = list(
        reality = reality,
        possibility = possibility,
        summary_of_differences = trimws(difflist, which = "right"),
        update_time = UTC_timestamp(Sys.time()),
        NULL
      )
    )
    if (fs::is_dir(".git")) fs::dir_delete(".git")
  })
}


# If the git user is not set, we set a temporary one, note that this is paired
# with reset_git_user()
check_git_user <- function(path, name = "carpenter", email = "team@carpentries.org") {
  if (!gert::user_is_configured(path)) {
    gert::git_config_set("user.name", name, repo = path)
    gert::git_config_set("user.email", email, repo = path)
  }
}

# It's clear that we cannot rely on folks having the correct libgit2 version,
# so the way we enforce the main branch is to do it after we make the initial
# commit like so:
#
#  1. create a new branch called "main"
#  2. change "master" to "main" in .git/HEAD (txt file)
#  3. delete "master" branch
#
# If the user HAS set a default branch, we will use that one.
enforce_main_branch <- function(path) {
  current <- gert::git_branch(path)
  default <- get_default_branch()
  if (current != "master") {
    # the user set up their init.defaultBranch correctly
    return(path)
  }
  # Create and move to main branch
  gert::git_branch_create(default, repo = path)
  # modify .git/HEAD file
  HFILE <- file.path(path, ".git", "HEAD")
  HEAD <- readLines(HFILE, encoding = "UTF-8")
  writeLines(sub("master", default, HEAD), HFILE)
  # remove master
  gert::git_branch_delete("master", repo = path)
}

get_default_branch <- function() {
  cfg <- gert::git_config_global()
  default <- cfg$value[cfg$name == "init.defaultbranch"]
  # See https://github.com/carpentries/sandpaper/issues/516
  # If the user accidentally has two init.defatulBranch statements in their
  # global .gitconfig, then we are going to choose the _last_ defined branch.
  #
  # The reason why we choose the _last_ defined branch is because this is what
  # the command line git does (see https://github.com/r-lib/gert/issues/196),
  # even if it's not what libgit2 does.
  #
  # NOTE: because this deals with global git configs, I do not really have the
  # capability to run a test here because this test would necessarily need to
  # modify the user's global git config, which I do _not_ want to do.
  n_defaults <- length(default)
  # no default branches can indicate an earlier version of git
  invalid <- n_defaults == 0 || default[n_defaults] == "master"
  if (invalid) "main" else default[n_defaults]
}

# This checks if we have set a temporary git user and then unsets it. It will
# supriously unset a user if they happened to have
# "carpenter <team@carpentries.org>" as their email.
reset_git_user <- function(path) {
  cfg <- gert::git_config(path)
  it_me <- cfg$value[cfg$name == "user.name"] == "carpenter" &&
    cfg$value[cfg$name == "user.email"] == "team@carpentries.org"
  if (gert::user_is_configured(path) && it_me) {
    gert::git_config_set("user.name", NULL, repo = path)
    gert::git_config_set("user.email", NULL, repo = path)
  }
}

