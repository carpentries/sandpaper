verify_github_pat_available <- function() {
  if (nzchar(Sys.getenv("GITHUB_PAT"))) {
    cli::cli_alert_info("GITHUB_PAT available.")
    return(invisible(TRUE))
  }

  # Fall back to GITHUB_TOKEN
  if (nzchar(Sys.getenv("GITHUB_TOKEN"))) {
    Sys.setenv("GITHUB_PAT" = Sys.getenv("GITHUB_TOKEN"))
    cli::cli_alert_info("GITHUB_TOKEN available.")
    return(invisible(TRUE))
  }

  # Fall back to gh::gh_token()
  if (requireNamespace("gh", quietly = TRUE)) {
    token <- tryCatch(gh::gh_token(), error = function(e) "")
    if (nzchar(token)) {
      Sys.setenv("GITHUB_PAT" = token)
      cli::cli_alert_info("GITHUB_PAT temporarily assigned by gh::gh_token().")
      withr::defer(Sys.unsetenv("GITHUB_PAT"), teardown_env())
      return(invisible(TRUE))
    }
  }

  cli::cli_alert_warning("No GitHub token available. API rate limits may apply.")
  return(invisible(FALSE))
}

{
  # We can not use the package cache on Windows
  options(sandpaper.use_renv = renv_is_allowed())
  restore_fixture <- create_test_lesson()
  res <- tmp <- getOption("sandpaper.test_fixture")
  rmt <- fs::file_temp(pattern = "REMOTE-")
  setup_local_remote(repo = tmp, remote = rmt, verbose = FALSE)

  verify_github_pat_available()

  noise <- interactive() || Sys.getenv("CI") == "true"
  if (noise) {
    cli::cli_alert_info("Current RENV_PATHS_ROOT {Sys.getenv('RENV_PATHS_ROOT')}")
    cli::cli_alert_info("Current renv::paths$root() {renv::paths$root()}")
    cli::cli_alert_info(
      "{cli::symbol$arrow_down} Example lesson in {tmp}")
    cli::cli_alert_info(
      "{cli::symbol$arrow_up} Local remote in {rmt}"
    )
  }
}
# Run after all tests
withr::defer({
  tf <- getOption("sandpaper.test_fixture")
  options(sandpaper.test_fixture = NULL)
  rem <- remove_local_remote(repo = tf)
  # remove the test fixture and report
  res <- tryCatch(fs::dir_delete(tf), error = function() FALSE)
  noise <- interactive() || Sys.getenv("CI") == "true"
  if (noise) {
    status <- if (identical(res, FALSE)) "could not be" else "successfully"
    cli::cli_alert_info("{.file {tf}} {status} removed")
    if (is.character(rem)) {
      cli::cli_alert_info("local remote {.file {rem}} successfully removed")
    } else {
      cli::cli_alert_info("local remote could not be removed")
    }
  }
}, teardown_env())
