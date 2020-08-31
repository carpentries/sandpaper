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
  paste0("The .gitignore file is missing some elements: ", 
    paste(setdiff(GITIGNORED, eval(call$theirs, env)), collapse = ", ")
  )
}

## lesson name validator -------------------------------------------------------
check_episode_name <- function(path) {
  grepl("^[0-9]{2}[-]", fs::path_file(path))
}
assertthat::on_failure(check_episode_name) <- function(call, env) {
  paste0("The file '", eval(call$path, env), "' must start with a two-digit number") 
}

# reporting of validators ------------------------------------------------------
report_validation <- function(checklist, msg = "There were errors") {
  errs <- Filter(Negate(isTRUE), checklist)

  if (length(errs) == 0) return(invisible(TRUE))

  for (i in errs) {
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_danger(i)
    } else {
      msg <- paste(i, msg, sep = "\n", collapse = "\n")
    }
  }
  stop(msg)
}
