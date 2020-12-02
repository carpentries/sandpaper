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
ci_build_markdown <- function(path = ".", branch = "md-outputs", remote = "origin") {

  # step 0: build_lesson defaults to a local build
  path <- set_source_path(path)
  on.exit(reset_build_paths())

  create_site(path)

  built <- path_built(path)
  html  <- fs::path(path_site(path), "docs")

  cli::rule("PATHS")
  message(path)
  message(built)
  message(html)
  message(fs::path_wd())

  cli::rule("BRANCHES")
  message(remote, "/", branch)

  print(fs::dir_tree(path_site(path)))
  # Set up the worktrees and make sure to remove them when the function exits
  # (gracefully or ungracefully so)
  del_md <- git_worktree_setup(path, built, 
    branch = branch, remote = remote
  )

  on.exit(eval(del_md), add = TRUE)

  print(list.files(path_site(path)))

  build_markdown(path = path, quiet = TRUE, rebuild = FALSE)

  github_worktree_commit(built, 
    "markdown source builds",
    remote, branch
  )
}

ci_build_site <- function(path = ".", branch = "gh-pages", md = "md-outputs", remote = "origin") {

  # step 0: build_lesson defaults to a local build
  path <- set_source_path(path)
  on.exit(reset_build_paths())

  create_site(path)

  built <- path_built(path)
  html  <- fs::path(path_site(path), "docs")

  # Set up the worktrees and make sure to remove them when the function exits
  # (gracefully or ungracefully so)
  # ------------ markdown worktree
  del_md <- git_worktree_setup(path, built, 
    branch = md, remote = remote
  )
  on.exit(eval(del_md), add = TRUE)

  # ------------ site worktree
  del_site <- git_worktree_setup(path, html,
    branch = branch, remote = remote
  )

  on.exit(eval(del_site), add = TRUE)

  # Will not rebuild the files that were already built
  build_site(path = path, quiet = TRUE, rebuild = FALSE)

  github_worktree_commit(html,
    "site deploy",
    remote, branch
  )
}
