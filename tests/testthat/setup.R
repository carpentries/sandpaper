{
if (interactive()) {
  try({
stat <- cli::cli_status("{cli::symbol$arrow_right} Bootstrapping example lesson")
  })
}
tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp <- fs::path(tmpdir, "lesson-example")
if (interactive()) {
  try({
    cli::cli_status_update(id = stat,
      "{cli::symbol$arrow_right} Bootstrapping example lesson in {tmp}"
    )
  })
}
res <- create_lesson(tmp, open = FALSE)

options(sandpaper.test_fixture = res)

generate_restore_fixture <- function(tf) {
  function() {
    if (nrow(gert::git_status(repo = tf)) > 0L) {
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
}

restore_fixture <- generate_restore_fixture(res)

if (interactive()) {
  try({
    cli::cli_alert_info(id = stat, "Example lesson in {tmp}")
  })
}

# Run after all tests
withr::defer({
  tf <- getOption("sandpaper.test_fixture")
  fs::dir_delete(tf)
  if (interactive() && !fs::dir_exists(tf)) {
    if (!fs::dir_exists(tf)) 
      try(cli::cli_alert_info("{tf} successfully removed"))
    else
      try(cli::cli_alert_danger("{tf} could not be removed"))
  }
}, teardown_env())
}
