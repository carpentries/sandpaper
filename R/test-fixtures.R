#nocov-start
#' Test fixture functions for sandpaper
#'
#' These functions are for use during testing of {sandpaper} and are designed to
#' create a temporary lesson and associated remote repository (locally).
#'
#' ## create_test_lesson() 
#'
#' This creates the test lesson and returns a function that will restore the
#' test fixture when called with no arguments
#'
#' ## generate_restore_fixture()
#'
#' This creates the restore function for the test lesson
#'
#' ## setup_local_remote()
#'
#' Creates a local remote repository in a separate temporary folder, linked to
#' the fixture lesson
#'
#' ## remove_local_remote() 
#'
#' Destorys the local remote repository and removes it from the fixture lesson
#'
#' @note These are implemented in tests/testthat/setup.md
#' @keywords internal
#' @rdname fixtures
create_test_lesson <- function() {
  if (interactive()) {
    cli::cli_status("{cli::symbol$arrow_right} Bootstrapping example lesson")
  }
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp <- fs::path(tmpdir, "lesson-example")
  if (interactive()) {
    cli::cli_status_update(
      "{cli::symbol$arrow_right} Bootstrapping example lesson in {tmp}"
    )
  }
  create_lesson(tmp, open = FALSE)
  options(sandpaper.test_fixture = tmp)
  generate_restore_fixture(tmp)
}

#' @param tf (`generate_restore_fixture()`) the path to the test fixture lesson
#' @return (`generate_restore_fixture`) a function that will restore the test fixture
#' @rdname fixtures
generate_restore_fixture <- function(tf) {
  function() {
    if (nrow(gert::git_status(repo = tf)) > 0L) {
      # reset the repositoyr
      x <- gert::git_reset_hard(repo = tf)
      # clean up any files that were not tracked and restore untracked dirs
      if (nrow(x) > 0L) {
        files <- fs::path(tf, x$file)
        dirs  <- fs::is_dir(files)
        tryCatch({
          fs::file_delete(files[!dirs])
          fs::dir_delete(files[dirs])
        },
          error = function(x) {}
        )
        if (any(dirs)) {
          fs::dir_create(files[dirs])
        }
      }
    }
    # clear the site and recreate it
    fs::dir_delete(fs::path(tf, "site"))
    create_site(tf)
    tf
  }
}

#' @param repo path to a git repository
#' @param remote path to an empty or uninitialized directory. Defaults to a
#'   tempfile
#' @param name of the remote, defaults to "sandpaper-local"
#' @param verbose if `TRUE`, messages and output from git will be printed to
#'   screen. Defaults to `FALSE`.
#' @return (`setup_local_remote()`) the repo, invisibly
#' @rdname fixtures
#' @keywords internal
setup_local_remote <- function(repo, remote = tempfile(), name = "sandpaper-local", verbose = FALSE) {
  tf <- getOption("sandpaper.test_fixture")
  stopifnot("This should only be run in a test context" = !is.null(tf))
  if (!fs::dir_exists(remote)) {
    fs::dir_create(remote)
  }
  gert::git_clone(repo, path = remote, bare = TRUE)
  gert::git_remote_remove(remote = "origin", repo = remote)
  gert::git_remote_add(remote, name, repo = repo)
  gert::git_push(remote = name, set_upstream = TRUE, repo = repo, verbose = verbose)
  return(invisible(repo))
}

# create and clean branches in the local and remote repositories
make_branch <- function(repo, ..., remote_name = "sandpaper-local", verbose = FALSE) {
  gert::git_branch_create(..., repo = repo)
  gert::git_push(remote = remote_name, repo = repo, verbose = verbose)
}

clean_branch <- function(repo, nu_branch = NULL, remote_name = "sandpaper-local", verbose = FALSE) {
  this_branch <- gert::git_branch(repo)
  if (is.null(nu_branch) || this_branch == nu_branch) {
    gert::git_branch_checkout("main", repo = repo)
  }
  gert::git_branch_delete(nu_branch, repo = repo)
  rmt_url <- gert::git_remote_list(repo)
  rmt_url <- rmt_url$url[rmt_url$name == remote_name]
  if (length(rmt_url) > 0) { 
    gert::git_branch_delete(nu_branch, repo = rmt_url)
  }
}

#' @rdname fixtures
#' @return (`remove_local_remote()`) FALSE indicating an error or a string 
#'   indicating the path to the remote
remove_local_remote <- function(repo, name = "sandpaper-local") {
  if (name == "origin") {
    return(repo)
  }
  remotes <- tryCatch(gert::git_remote_list(repo = repo),
    error = function(e) data.frame(name = character(0))
  )
  if (any(the_remote <- remotes$name %in% name)) {
    gert::git_remote_remove(name, repo)
    to_remove <- remotes$url[the_remote]
    # don't error if we can not delete this.
    return(tryCatch(fs::dir_delete(to_remove), error = function() FALSE))
  }
  return(invisible("(no remote present)"))
}
#nocov-end
