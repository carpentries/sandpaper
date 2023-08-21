{
  # We can not use the package cache on Windows
  options(sandpaper.use_renv = renv_is_allowed())
  restore_fixture <- create_test_lesson()
  res <- tmp <- getOption("sandpaper.test_fixture")
  rmt <- fs::file_temp(pattern = "REMOTE-")
  setup_local_remote(repo = tmp, remote = rmt, verbose = FALSE)

  no_gh_token <- !nzchar(Sys.getenv("GITHUB_PAT"))
  if (no_gh_token && requireNamespace("gh", quietly = TRUE)) {
    Sys.setenv("GITHUB_PAT" = gh::gh_token())
    withr::defer(Sys.unsetenv("GITHUB_PAT"), teardown_env())
  }
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
    status <- if (is.character(rem)) "successfully" else "could not be"
    cli::cli_alert_info("local remote {.file {rem}} {status} removed")
  }
}, teardown_env())
