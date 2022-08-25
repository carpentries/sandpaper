#' Create an Episode from a template
#'
#' @param title the title of the episode
#' @param ext a character. If `ext = "Rmd"` (default), then the new episode will
#'   be an R Markdown episode. If `ext = "md"`, then the new episode will be
#'   a markdown episode, which can not generate dynamic content.
#' @param make_prefix a logical. When `TRUE`, the prefix for the file will be
#'   automatically determined by the files already present. When `FALSE`
#'   (default), it assumes no prefix is needed.
#' @param path the path to the {sandpaper} lesson.
#' @param add if `TRUE`, the lesson is added to the schedule. Defaults to `FALSE`
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' create_episode_md("getting-started", path = tmp)
create_episode <- function(title, ext = "Rmd", make_prefix = FALSE, add = FALSE, path = ".") {
  check_lesson(path)
  ext <- switch(match.arg(tolower(ext), c("rmd", "md")), rmd = ".Rmd", md = ".md")
  prefix <- ""
  if (make_prefix) {
    episodes <- fs::path_file(fs::dir_ls(path_episodes(path), regexp = "*.[Rr]?md"))
    suppressWarnings(prefix <- as.integer(sub("^([0-9]{2}).+$", "\\1", episodes)))
    no_prefix <- length(prefix) == 0 || all(is.na(prefix))
    prefix <- if (no_prefix) "01-" else sprintf("%02d-", max(prefix, na.rm = TRUE) + 1L)
  }
  slug <- slugify(title)
  ename <- paste0(prefix, slug, ext)
  copy_template("episode", fs::path(path, "episodes"), ename, 
    values = list(title = siQuote(title), md = ext == ".md"))
  if (add) {
    suppressWarnings(sched <- get_episodes(path))
    set_episodes(path, c(sched, ename), write = TRUE)
  }
  invisible(fs::path(path, "episodes", ename))
}

#' @export
#' @rdname create_episode
create_episode_md <- function(title, make_prefix = TRUE, add = FALSE, path = ".") {
  create_episode(title, ext = "md", make_prefix = make_prefix, add = add, path = path)
}

#' @export
#' @rdname create_episode
create_episode_rmd <- function(title, make_prefix = TRUE, add = FALSE, path = ".") {
  create_episode(title, ext = "Rmd", make_prefix = make_prefix, add = add, path = path)
}
