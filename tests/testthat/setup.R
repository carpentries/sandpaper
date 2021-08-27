{
  if (.Platform$OS.type == "windows") {
    # We can not use the package cache on Windows
    options(sandpaper.use_renv = FALSE)
  }
  restore_fixture <- create_test_lesson()
  res <- tmp <- getOption("sandpaper.test_fixture")
  rmt <- fs::file_temp(pattern = "REMOTE-")
  setup_local_remote(repo = tmp, remote = rmt, verbose = FALSE)

  if (interactive()) {
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
  if (interactive()) {
    status <- if (identical(res, FALSE)) "could not be" else "successfully"
    cli::cli_alert_info("{.file {tf}} {status} removed")
    status <- if (is.character(rem)) "successfully" else "could not be"
    cli::cli_alert_info("local remote {.file {rem}} {status} removed")
  }
}, teardown_env())
