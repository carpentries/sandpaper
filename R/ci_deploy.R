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
#'   `site/` folder. 
#' 
#' @keywords internal
ci_deploy <- function(path = ".", md_branch = "md-outputs", site_branch = "gh-pages", remote = "origin") {

  if (interactive() && is.null(getOption('sandpaper.test_fixture'))) {
    stop("This function is for use on continuous integration only", call. = FALSE)
  }
  # step 0: build_lesson defaults to a local build
  path <- set_source_path(path)
  current <- gert::git_branch(path)
  on.exit(reset_build_paths())

  create_site(path)

  built <- path_built(path)
  html  <- fs::path(path_site(path), "docs")
  has_withr <- requireNamespace("withr", quietly = TRUE)

  if (has_git() && has_withr) { withr::with_dir(path, {
    # Set up the worktrees and make sure to remove them when the function exits
    # (gracefully or ungracefully so)
    # ------------ markdown worktree
    del_md <- git_worktree_setup(path, built, 
      branch = md_branch, remote = remote
    )
    on.exit(eval(del_md), add = TRUE)

    # ------------ site worktree
    del_site <- git_worktree_setup(path, html,
      branch = site_branch, remote = remote
    )

    on.exit(eval(del_site), add = TRUE)

    # Build the site quickly using the markdown files as-is
    build_lesson(path = path, quiet = TRUE, rebuild = FALSE, preview = FALSE)

    # Commit the markdown sources
    github_worktree_commit(built, 
      message_source("markdown source builds", current, dir = path),
      remote, md_branch 
    )

    # Commit using the markdown branch as a reference
    github_worktree_commit(html,
      message_source("site deploy", md_branch, dir = built),
      remote, site_branch
    )
  })}
  invisible()
}

