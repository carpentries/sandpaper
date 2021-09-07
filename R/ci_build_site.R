ci_build_site <- function(path = ".", branch = "gh-pages", md = "md-outputs", remote = "origin") {

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
