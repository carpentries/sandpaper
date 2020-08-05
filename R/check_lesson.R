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
check_lesson <- function(path = ".") {

  x     <- fs::dir_info(path, all = TRUE)
  files <- fs::path_file(x$path)

  check_dir <- function(path, i) {
    assertthat::see_if(assertthat::is.dir(fs::path(path, i)),
      msg = paste0(i, "/ does not exist")
    )
  }

  check_gitignore <- function(path) {
    g <- fs::path(path, ".gitignore")
    if (fs::file_exists(g)) {
      theirs <- readLines(g)
      ours   <- readLines(system.file("gitignore.txt", package = "sandpaper"))
      assertthat::see_if(length(setdiff(ours, theirs)) == 0, 
        msg = ".gitignore does not contain the correct elements"
      )
    } else {
      assertthat::see_if(FALSE, msg = ".gitignore does not exist")
    }
  }


  checklist <- list(
    check_dir(path, "episodes"),
    check_dir(path, "site"),
    check_dir(path, ".git"),
    check_gitignore(path)
  )

  if (all(unlist(checklist, use.names = FALSE))) return(invisible(TRUE))

  msg <- "There were errors with the lesson structure"
  for (i in Filter(isFALSE, checklist)) {
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_danger(attr(i, "msg"))
    } else {
      msg <- paste(attr(i, "msg"), msg, sep = "\n")
    }
  }
  stop(msg)
}
