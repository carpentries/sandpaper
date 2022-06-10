# assertthat Validators --------------------------------------------------------


## Directory is valid ----------------------------------------------------------
check_dir <- function(path, i) {
  assertthat::is.dir(fs::path(path, i))
}
assertthat::on_failure(check_dir) <- function(call, env) {
  paste0("The folder '", eval(call$i, envir = env), "' does not exist")
}

## File exists -----------------------------------------------------------------
check_exists <- function(path, i) fs::file_exists(fs::path(path, i))
assertthat::on_failure(check_exists) <- function(call, env) {
  paste0("The file '", eval(call$i, envir = env), "' does not exist")
}

## .gitignore is valid ---------------------------------------------------------
check_gitignore <- function(theirs) {
  length(setdiff(GITIGNORED, theirs)) == 0
}
assertthat::on_failure(check_gitignore) <- function(call, env) {
  paste0("The .gitignore file is missing the following elements:\n", 
    paste(setdiff(GITIGNORED, eval(call$theirs, env)), collapse = "\n")
  )
}

# reporting of validators ------------------------------------------------------
report_validation <- function(checklist, msg = "There were errors") {
  errs <- Filter(Negate(isTRUE), checklist)

  if (length(errs) == 0) return(invisible(TRUE))

  cli::cli_div(theme = sandpaper_cli_theme())
  on.exit(cli::cli_end(), add = TRUE)
  for (i in errs) {
    cli::cli_alert_danger(i)
  }
  stop(msg)
}
