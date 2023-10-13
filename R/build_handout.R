#' Create a code handout of challenges without solutions
#'
#' This function will build a handout and save it to `files/code-handout.R`
#' in your lesson website. This will build with your website if you enable it
#' with `options(sandpaper.handout = TRUE)` or if you want to specify a path,
#' you can use `options(sandpaper.handout = "/path/to/handout.R")` to save the
#' handout to a specific path.
#'
#' @export
#' @param path the path to the lesson. Defaults to current working directory
#' @param out the path to the handout document. When this is `NULL` (default)
#'   or `TRUE`, the output will be `site/built/files/code-handout.R`.
#' @return NULL
build_handout <- function(path = ".", out = NULL) {
  path <- root_path(path)
  lesson <- this_lesson(path)
  tmp <- fs::file_temp(ext = "R")
  tryCatch({
    lesson$handout(tmp)
    if (is.null(out) || !isFALSE(out) && isTRUE(out)) {
      out <- fs::path(path_built(path), "files", "code-handout.R")
    }
    knitr::purl(tmp, out, documentation = 2, quiet = TRUE)
    cli::cli_alert_info("handout created at {.file {out}}")
  }, error = function(e) {
    msg <- paste0("handout could not be built and threw an error:\n", e$message)
    cli::cli_alert_warning(msg)
  })
  NULL
}
