{
cli::cli_alert_info("Bootstrapping example lesson")

tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp <- fs::path(tmpdir, "lesson-example")
res <- create_lesson(tmp, open = FALSE)

options(sandpaper.test_fixture = res)

restore_fixture <- function() {
  tf <- getOption("sandpaper.test_fixture")
  if (nrow(gert::git_status(tf)) > 0L) {
    x <- gert::git_reset_hard(repo = tf)
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
  fs::dir_delete(fs::path(tf, "site"))
  create_site(tf)
  tf
}


# Run after all tests
withr::defer(fs::dir_delete(getOption("sandpaper.test_fixture")), teardown_env())
}
