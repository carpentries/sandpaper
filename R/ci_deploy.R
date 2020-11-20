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

  # step 0: build_lesson defaults to a local build
  path <- set_source_path(path)
  on.exit(reset_build_paths())

  built <- path_built(path)
  html  <- fs::path(path_site(path), "docs")

  cli::rule("PATHS")
  message(path)
  message(built)
  message(html)
  message(fs::path_wd())

  cli::rule("BRANCHES")
  message(remote, "/", md_branch)
  message(remote, "/", site_branch)

  # Set up the worktrees and make sure to remove them when the function exits
  # (gracefully or ungracefully so)
  del_md <- git_worktree_setup(path, built, 
    branch = md_branch, remote = remote
  )
  on.exit(eval(del_md), add = TRUE)

  build_markdown(path = path, quiet = TRUE, rebuild = FALSE)

  github_worktree_commit(built, 
    "markdown source builds",
    remote, md_branch
  )

  del_site <- git_worktree_setup(path, html, 
    branch = site_branch, remote = remote
  )
  on.exit(eval(del_site), add = TRUE)
  build_lesson(path, quiet = TRUE, preview = FALSE)
  writeLines("", fs::path(html, ".nojekyll"))
  github_worktree_commit(html,
    "deploy site",
    remote, site_branch
  )
}

git_worktree_setup <- function (path = ".", dest_dir, branch = "gh-pages", remote = "origin") {

  no_branch <- !git_has_remote_branch(remote, branch)
  
  # create the branch if it doesn't exist
  if (no_branch) {
    old_branch <- gert::git_branch(repo = path)
    git("checkout", "--orphan", branch)
    git("rm", "-rf", "--quiet", ".")
    git("commit", "--allow-empty", "-m", 
      sprintf("Initializing %s branch", branch)
    )
    git("push", remote, paste0("HEAD:", branch))
    git("checkout", old_branch)
  }
  # fetch the content of only the branch in question
  # https://stackoverflow.com/a/62264058/2752888
  git("remote", "set-branches", remote, branch)
  git("fetch", remote, branch)
  github_worktree_add(dest_dir, remote, branch)
  # This allows me to evaluate this expression at the top of the calling
  # function.
  parse(text = paste0("github_worktree_remove('", dest_dir, "')"))
}



# Shamelessly stolen from {pkgdown}, originally authored by Hadley Wickam
git <- function (..., echo_cmd = TRUE, echo = TRUE, error_on_status = TRUE) {
  callr::run("git", c(...), echo_cmd = echo_cmd, echo = echo, 
    error_on_status = error_on_status)
}

git_has_remote_branch <- function (remote, branch) {
  has_remote_branch <- git("ls-remote", "--quiet", "--exit-code", 
    remote, branch, echo = FALSE, echo_cmd = FALSE, error_on_status = FALSE)$status == 
  0
}

github_worktree_add <- function (dir, remote, branch) {
  if (requireNamespace("cli", quietly = TRUE))
    cli::rule("Adding worktree", line = "+")
  git("worktree", "add", 
    "--track", "-B", branch, dir, 
    paste0(remote, "/", branch)
  )
}


github_worktree_commit <- function (dir, commit_message, remote, branch) {
    force(commit_message)
    if (requireNamespace("cli", quietly = TRUE))
      cli::rule("Committing", line = "c")
    if (!requireNamespace("withr", quietly = TRUE))
      stop("withr must be installed")
    withr::with_dir(dir, {
        git("add", "-A", ".")
        git("commit", "--allow-empty", "-m", commit_message)
        cli::rule("Deploying", line = 1)
        git("remote", "-v")
        git("push", "--force", remote, paste0("HEAD:", branch))
    })
}

github_worktree_remove <- function (dir) {
  if (requireNamespace("cli", quietly = TRUE)) 
    cli::rule("Removing worktree", line = "-")
  git("worktree", "remove", "--force", dir)
}


#   pkg <- as_pkgdown(pkg, override = list(destination = dest_dir))
#   if (clean) {
#     rule("Cleaning files from old site", line = 1)
#     clean_site(pkg)
#   }
#   build_site(pkg, devel = FALSE, preview = FALSE, install = FALSE, 
#     ...)
#   if (github_pages) {
#     build_github_pages(pkg)
#   }
#   github_push(dest_dir, commit_message, remote, branch)
#   invisible()
# }

# <bytecode: 0x7646870>
# <environment: namespace:pkgdown>

# function (pkg = ".") 
# {
#     rule("Extra files for GitHub pages")
#     pkg <- as_pkgdown(pkg)
#     write_if_different(pkg, "", ".nojekyll", check = FALSE)
#     cname <- cname_url(pkg$meta$url)
#     if (is.null(cname)) {
#         return(invisible())
#     }
#     write_if_different(pkg, cname, "CNAME", check = FALSE)
#     invisible()
# }
# <bytecode: 0x74072e8>
# <environment: namespace:pkgdown>
