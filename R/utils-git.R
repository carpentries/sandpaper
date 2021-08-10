has_git <- function() {
  Sys.which("git") != ""
}

# Shamelessly stolen from {pkgdown}, originally authored by Hadley Wickam
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

# worktree setup
# [IF BRANCH DOES NOT EXIST]
#   git checkout --orphan <branch>
#   git rm -rf --quiet .
#   git commit --allow-empty -m
#   git push remote HEAD:<branch>
#   git checkout -
# git remote set-branches <remote> <branch>
# git fetch <remote> <branch>
# git worktree add --track -B <branch> /path/to/dir <remote>/<branch>
#
# Modified from pkgdown::deploy_to_branch() by Hadley Wickham
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


# Add a branch to a folder as a worktree
# originally authored by Hadley Wickham
github_worktree_add <- function (dir, remote, branch) {
  if (requireNamespace("cli", quietly = TRUE))
    cli::rule("Adding worktree", line = "+")
  git("worktree", "add", 
    "--track", "-B", branch, dir, 
    paste0(remote, "/", branch)
  )
}

# Commit on a worktree
# Modified from pkgdown:::github_push by Hadley Wickham
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
      message("nothing to commit!")
      return(NULL)
    }
    git("commit", "--allow-empty", "-m", commit_message)
    cli::rule("Deploying", line = 1)
    git("remote", "-v")
    git("push", "--force", remote, paste0("HEAD:", branch))
  })
}

# Remove a git worktree
# Modified from pkgdown:::github_worktree_remove by Hadley Wickham
github_worktree_remove <- function (dir) {
  if (requireNamespace("cli", quietly = TRUE)) 
    cli::rule("Removing worktree", line = "-")
  # ZNK: add --force
  home <- root_path(dir)
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
    "\nAuto-generated via {sandpaper}\n",
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
#     bundle_pr_artifacts(
#       repo         = '${{ github.repository }}',
#       pr_number    = '${{ github.event.number }}',
#       path_md      = '${{ env.MD }}',
#       path_pr      = '${{ env.PR }}',
#       path_archive = '${{ env.CHIVE }}',
#       branch       = "md-outputs"
#     )
#   shell: Rscript {0}
bundle_pr_artifacts <- function(repo, pr_number, 
  path_md, path_archive, path_pr, 
  branch = "md-outputs") {
  if (!fs::dir_exists(path_archive)) fs::dir_create(path_archive)
  if (!fs::dir_exists(path_pr)) fs::dir_create(path_pr)
  writeLines(pr_number, fs::path(path_pr, "NR"))
  if (!requireNamespace("withr", quietly = TRUE))
    stop("withr must be installed")
  withr::with_dir(path_md, {
    git("add", "-A", ".")
    difflist <- git("diff", "--staged", "--compact-summary",
      echo = FALSE, echo_cmd = FALSE)
    github_url  <- glue::glue("https://github.com/{repo}/compare/")
    change_link <- glue::glue("{github_url}{branch}..{branch}-PR-{pr_number}")
    msg         <- glue::glue(
      "### Rendered Changes

      :mag: Inspect the changes: {change_link}

      ---

      The following changes were observed in the rendered markdown documents

      ```diff
      {difflist}
      ```

      <details>
      <summary>What does this mean?</summary>

      If you have source files that require output and figures to be generated
      (e.g. R Markdown), then it is important to make sure the generated 
      figures and output are reproducible. 

      This output provides a way for you to inspect the output in a 
      diff-friendly manner so that it's easy to see the changes that occurr due
      to new software versions or randomisation.

      <details>
      "
    )
    writeLines(msg, fs::path(path_archive, "diff.md"))
    fs::dir_delete(".git")
  })
}


