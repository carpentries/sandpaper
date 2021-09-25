#' Create a code handout of challenges without solutions
#'
#' @param path the path to the lesson. Defaults to current working directory
#' @return 
build_handout <- function(path = ".") {
  lesson <- this_lesson(path)
  tmp <- fs::file_temp(ext = "R")
  tryCatch({
    lesson$handout(tmp)
    out <- fs::path(path_built(path), "files", "code-handout.R")
    knitr::purl(tmp, out, documentation = 2, quiet = TRUE)
  }, error = function(e) {
    msg <- paste0("handout could not be built and threw an error:\n", e$message)
    cli::cli_alert_warning(msg)
  })
  NULL
}
