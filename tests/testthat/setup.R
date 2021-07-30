{
# Creating the Lesson ----------------------------------------------------------
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
# Creating the Repository ------------------------------------------------------
rmt <- fs::file_temp(pattern = "REMOTE-")
options(sandpaper.test_fixture = res)

setup_local_remote(repo = tmp, remote = rmt, verbose = FALSE)


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
    cli::cli_alert_info(id = stat, 
      "{cli::symbol$arrow_down} Example lesson in {tmp}")
    cli::cli_alert_info(id = stat, 
      "{cli::symbol$arrow_up} Local remote in {rmt}"
    )
  })
}

# Run after all tests
withr::defer({
  tf <- getOption("sandpaper.test_fixture")
  rem <- remove_local_remote(repo = tf)
  res <- tryCatch(fs::dir_delete(tf), error = function() FALSE)
  if (interactive()) {
    status <- if (identical(res, FALSE)) "could not be" else "successfully"
    try(cli::cli_alert_info("{tf} {status} removed"))
    status <- if(identical(rem, FALSE)) "could not be" else rem
    try(cli::cli_alert_info("remote {status} removed"))
  }
}, teardown_env())
}
