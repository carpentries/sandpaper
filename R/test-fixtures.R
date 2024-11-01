#' Test fixture functions for sandpaper
#'
#' @description
#'
#' This suite of functions are for use during testing of `{sandpaper}` and are
#' designed to create/work with a temporary lesson and associated remote
#' repository (locally) that persists throughout the test suite. These functions
#' are used in `tests/testthat/setup.R`. For more information, see the [package
#' scope section of testthat article on Test
#' Fixtures](https://testthat.r-lib.org/articles/test-fixtures.html#package).
#'
#' @details
#'
#' ## `create_test_lesson()`
#'
#' This creates the test lesson and calls `generate_restore_fixture()` with the
#' path of the new test lesson.
#'
#' @note These are implemented in tests/testthat/setup.md
#' @keywords internal
#' @rdname fixtures
create_test_lesson <- function() {
  noise <- interactive() || Sys.getenv("CI") == "true"
  if (noise) {
    t1 <- Sys.time()
    on.exit({
      ts <- format(Sys.time() - t1)
      cli::cli_alert_info("Lesson bootstrapped in {ts}")
    }, add = TRUE)
    cli::cli_status("{cli::symbol$arrow_right} Bootstrapping example lesson")
  }
  # We explicitly need the package cache for tests
  options("sandpaper.use_renv" = renv_is_allowed())
  repodir <- fs::file_temp()
  fs::dir_create(repodir)
  repo <- fs::path(repodir, "lesson-example")
  if (noise) {
    cli::cli_status_update(
      "{cli::symbol$arrow_right} Bootstrapping example lesson in {repo}"
    )
  }
  suppressMessages({
    withr::with_envvar(list(RENV_CONFIG_CACHE_SYMLINKS = FALSE), {
      renv_output <- utils::capture.output(
        create_lesson(repo, open = FALSE)
      )
    })
  })
  options(sandpaper.test_fixture = repo)
  options(sandpaper.test_fixture_output = renv_output)
  generate_restore_fixture(repo)
}

#' @details
#'
#' ## `generate_restore_fixture()`
#'
#' This creates a function that will restore a lesson to its previous commit.
#'
#' @return (`generate_restore_fixture`) a function that will restore the test fixture
#' @rdname fixtures
generate_restore_fixture <- function(repo) {
  function() {
    options("sandpaper.use_renv" = renv_is_allowed())
    if (nrow(gert::git_status(repo = repo)) > 0L) {
      # reset the repository
      x <- gert::git_reset_hard(repo = repo)
      # clean up any files that were not tracked and restore untracked dirs
      if (nrow(x) > 0L) {
        files <- fs::path(repo, x$file)
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
    fs::dir_delete(fs::path(repo, "site"))
    create_site(repo)
    # reset the lesson cache
    clear_this_lesson()
    set_this_lesson(repo)
    repo
  }
}

#' @param repo path to a git repository
#' @param remote path to an empty or uninitialized directory. Defaults to a
#'   tempfile
#' @param name of the remote, defaults to "sandpaper-local"
#' @param verbose if `TRUE`, messages and output from git will be printed to
#'   screen. Defaults to `FALSE`.
#' @details
#'
#' ## `setup_local_remote()`
#'
#' Creates a local remote repository in a separate temporary folder, linked to
#' the fixture lesson.
#'
#' @return (`setup_local_remote()`) the repo, invisibly
#' @rdname fixtures
#' @keywords internal
setup_local_remote <- function(repo, remote = tempfile(), name = "sandpaper-local", verbose = FALSE) {
  tf <- getOption("sandpaper.test_fixture")
  noise <- interactive() || Sys.getenv("CI") == "true"
  if (noise) {
    t1 <- Sys.time()
    on.exit({
      ts <- format(Sys.time() - t1)
      cli::cli_alert_info("Remote set up in {ts}")
    }, add = TRUE)
  }
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

#' @param branch the name of the new branch to be deleted
#' @details
#'
#' ## `make_branch()`
#'
#' create a branch in the local repository and push it to the remote repository.
#'
#' @rdname fixtures
make_branch <- function(repo, branch = NULL, name = "sandpaper-local", verbose = FALSE) {
  this_branch <- gert::git_branch(repo = repo)
  on.exit(gert::git_branch_checkout(this_branch, repo = repo))
  gert::git_branch_create(branch, repo = repo, checkout = TRUE)
  gert::git_push(remote = name, repo = repo, verbose = verbose)
}

#' @details
#'
#' ## `clean_branch()`
#'
#' delete a branch in the local and remote repository.
#'
#' @rdname fixtures
clean_branch <- function(repo, branch = NULL, name = "sandpaper-local", verbose = FALSE) {
  this_branch <- gert::git_branch(repo)
  if (is.null(branch) || this_branch == branch) {
    gert::git_branch_checkout("main", repo = repo)
  }
  gert::git_branch_delete(branch, repo = repo)
  rmt_url <- gert::git_remote_list(repo)
  rmt_url <- rmt_url$url[rmt_url$name == name]
  if (length(rmt_url) > 0) {
    gert::git_branch_delete(branch, repo = rmt_url)
  }
}

#' @details
#'
#' ## `remove_local_remote()`
#'
#' Destorys the local remote repository and removes it from the fixture lesson
#'
#' @return (`remove_local_remote()`) FALSE indicating an error or a string
#'   indicating the path to the remote
#' @rdname fixtures
remove_local_remote <- function(repo, name = "sandpaper-local") {
  if (name == "origin") {
    return(repo)
  }
  remotes <- tryCatch(gert::git_remote_list(repo = repo),
    error = function(e) {
      cli::cli_alert_danger("Error listing remotes")
      cli::cli_text(e$message)
      d <- data.frame(name = character(0))
      return(d)
    }
  )
  if (any(the_remote <- remotes$name %in% name)) {
    gert::git_remote_remove(name, repo)
    to_remove <- remotes$url[the_remote]
    cli::cli_alert_info("removing '{name}' ({.file {to_remove}})")
    # don't error if we can not delete this.
    res <- tryCatch(fs::dir_delete(to_remove),
      error = function(e) {
        cli::cli_alert_danger("Error trying to remove remote")
        cli::cli_text(e$message)
        return(FALSE)
      }
    )
    return(res)
  }
  return(invisible("(no remote present)"))
}
