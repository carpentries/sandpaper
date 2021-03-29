#' Create an Episode from a template
#'
#' @param title the title of the episode
#' @param make_prefix a logical. If `TRUE`, the prefix for the file will be
#'   automatically determined by the files already present. Otherwise, it assumes
#'   you have added the prefix.
#' @param path the path to the {sandpaper} lesson.
#' @param add if `TRUE`, the lesson is added to the schedule. Defaults to `FALSE`
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' create_episode("getting-started", path = tmp)
create_episode <- function(title, make_prefix = TRUE, add = FALSE, path = ".") {
  check_lesson(path)
  prefix <- ""
  if (make_prefix) {
    episodes <- fs::path_file(fs::dir_ls(path_episodes(path), regexp = "*.[Rr]?md"))
    suppressWarnings(prefix <- as.integer(sub("^([0-9]{2}).+$", "\\1", episodes)))
    no_prefix <- length(prefix) == 0 || all(is.na(prefix))
    prefix <- if (no_prefix) "01-" else sprintf("%02d-", max(prefix, na.rm = TRUE) + 1L)
  } 
  ename <- paste0(prefix, title, ".Rmd")
  copy_template("episode", fs::path(path, "episodes"), ename)
  if (add) {
    suppressWarnings(sched <- get_episodes(path))
    set_episodes(path, c(sched, ename), write = TRUE)
  }
  invisible(fs::path(path, "episodes", ename))
}
