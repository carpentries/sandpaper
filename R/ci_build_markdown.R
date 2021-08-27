#' (INTERNAL) Build and deploy the site with continous integration
#'
#' @param path path to the lesson
#' @param md_branch the branch name that contains the markdown outputs
#' @param site_branch the branch name that contains the full HTML site
#' @param remote the name of the git remote to which you should deploy.
#' @return NOTHING
#'
#' @note this function is not for interactive use. It requires git to be
#'   installed on your machine and will destroy anything you have in the
#'   `site/` folder. Additionally, this will set the `sandpaper.use_renv`
#'   option to TRUE, which means that it will _always_ use the {renv} 
#'   package cache.
#'
#' @keywords internal
ci_build_markdown <- function(path = ".", branch = "md-outputs", remote = "origin", reset = FALSE) {

  if (!identical(Sys.getenv("TESTTHAT"), "true") || .Platform$OS.type != "windows")
    # We do not want to use the cache here if we are in a Windows testing environment
    options(sandpaper.use_renv = TRUE)
  # step 0: build_lesson defaults to a local build
  path <- set_source_path(path)
  on.exit(reset_build_paths())
  current <- gert::git_branch(repo = path)

  create_site(path)

  built <- path_built(path)

  has_withr <- requireNamespace("withr", quietly = TRUE)

  if (has_git() && has_withr) { withr::with_dir(path, {
    # Set up the worktrees and make sure to remove them when the function exits
    # (gracefully or ungracefully so)
    del_md <- git_worktree_setup(path, built, 
      branch = branch, remote = remote
    )
    if (reset) {
      ci_group("Reset Lesson")
      git_clean_everything(built)
      cli::cat_line("::endgroup::")
    }

    ci_group("Build Markdown Sources")
    build_markdown(path = path, quiet = FALSE, rebuild = FALSE)
    cli::cat_line("::endgroup::")

    ci_group("Commit Markdown Sources")
    github_worktree_commit(built, 
      message_source("markdown source builds", current, dir = path),
      remote, branch
    )
    cli::cat_line("::endgroup::")

  })}

  return(del_md)
}

