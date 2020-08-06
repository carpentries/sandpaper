#' Check the lesson structure for errors
#'
#' @param path the path to your lesson
#'
#' @return `TRUE` (invisibly) if the lesson is cromulent, otherwise, it will
#'   error with a list of things to fix.
#'
#' @export
#' @examples
#'
#' # Everything should work out of the box
#' tmp <- tempfile()
#' create_lesson(tmp)
#' check_lesson(tmp)
#'
#' # if things do not work, then an error is thrown with information about 
#' # what has failed you
#' unlink(file.path(tmp, ".gitignore"))
#' unlink(file.path(tmp, "site"), recursive = TRUE)
#' try(check_lesson(tmp))
#' 
#' unlink(tmp)
#' @importFrom assertthat validate_that
check_lesson <- function(path = ".") {

  x      <- fs::dir_info(path, all = TRUE)
  files  <- fs::path_file(x$path)
  # gitingore
  g      <- fs::path(path, ".gitignore")
  theirs <- if (fs::file_exists(g)) readLines(g) else character(0)
  theirs <- theirs[!grepl("^([#].+?|)$", trimws(theirs))]

  # Validation -----------------------------------------------------------------

  # Validators are stored in validators.R
  checklist <- list(
    validate_that(check_dir(path, "episodes")),
    validate_that(check_dir(path, "site")),
    validate_that(check_dir(path, ".git")),
    validate_that(check_gitignore(theirs)),
    validate_that(check_exists(path, "README.md")),
    validate_that(check_exists(path, fs::path("site", "README.md")))
  )

  # Reporting ------------------------------------------------------------------
  report_validation(
    checklist,
    "There were errors with the lesson structure."
  )
}
