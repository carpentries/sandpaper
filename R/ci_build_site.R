#' (INTERNAL) Build and deploy the site with continous integration
#'
#' @param path path to the lesson
#' @param branch the branch name that contains the full HTML site
#' @param md the branch name that contains the markdown outputs
#' @param remote the name of the git remote to which you should deploy.
#' @param reset if `TRUE`, the contents of the branch/folder will be cleared
#'   before inserting new items
#' @return NOTHING
#'
#' @note this function is not for interactive use. It requires git to be
#'   installed on your machine and will destroy anything you have in the
#'   `site/` folder. Additionally, this will set the `sandpaper.use_renv`
#'   option to TRUE, which means that it will _always_ use the {renv} 
#'   package cache.
#'
#' @keywords internal
ci_build_site <- function(path = ".", branch = "gh-pages", md = "md-outputs", remote = "origin", reset = FALSE) {

  # step 0: build_lesson defaults to a local build
  path <- set_source_path(path)
  current <- gert::git_branch(path)
  on.exit(reset_build_paths())

  create_site(path)

  built <- path_built(path)
  html  <- fs::path(path_site(path), "docs")

  has_withr <- requireNamespace("withr", quietly = TRUE)

  if (has_git() && has_withr) { withr::with_dir(path, {

    # ------------ markdown worktree
    # We need to first check if the markdown source files exist locally. If they
    # do not, we need to fetch them as a throwaway branch
    need_markdown_sources <- nrow(get_built_db()) == 0L
    if (need_markdown_sources) {
      del_md <- git_worktree_setup(path, built, 
        branch = md, remote = remote
      )
      on.exit(eval(del_md), add = TRUE)
    }

    # ------------ site worktree
    del_site <- git_worktree_setup(path, html,
      branch = branch, remote = remote
    )

    # remove the worktree at the end since this is the last step
    on.exit(eval(del_site), add = TRUE)

    if (reset) {
      ci_group("Reset Site")
      git_clean_everything(html)
      cli::cat_line("::endgroup::")
    }

    # Build the site quickly using the markdown files as-is
    ci_group("Build Lesson Website")
    build_site(path = path, quiet = FALSE, preview = FALSE)
    cli::cat_line("::endgroup::")

    # Commit using the markdown branch as a reference
    ci_group("Commit Lesson Website")
    github_worktree_commit(html,
      message_source("site deploy", md, dir = built),
      remote, branch
    )
    cli::cat_line("::endgroup::")
  })}
}
