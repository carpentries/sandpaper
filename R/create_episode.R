#' Create an Episode from a template
#'
#' These functions allow you to create an episode that will be added to the
#' schedule.
#'
#'
#' @param title the title of the episode
#' @param ext a character. If `ext = "Rmd"` (default), then the new episode will
#'   be an R Markdown episode. If `ext = "md"`, then the new episode will be
#'   a markdown episode, which can not generate dynamic content.
#' @param make_prefix a logical. When `TRUE`, the prefix for the file will be
#'   automatically determined by the files already present. When `FALSE`
#'   (default), it assumes no prefix is needed.
#' @param path the path to the `{sandpaper}` lesson.
#' @param add (logical or numeric) If numeric, it represents the position the
#'   episode should be added. If `TRUE`, the episode is added to the end of the
#'   schedule. If `FALSE`, the episode is added as a draft episode.
#' @param open if interactive, the episode will open in a new editor window.
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE, rmd = FALSE)
#' create_episode_md("getting-started", path = tmp)
create_episode <- function(title, ext = "Rmd", make_prefix = FALSE, add = TRUE, path = ".",
                           open = rlang::is_interactive()) {
  check_lesson(path)
  ext <- switch(match.arg(tolower(ext), c("rmd", "md")),
    rmd = ".Rmd",
    md = ".md"
  )
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
    values = list(title = siQuote(title), md = ext == ".md")
  )
  if (add) {
    move_episode(ename, position = add, write = TRUE, path = path)
  }
  new_file <- usethis::edit_file(fs::path(path, "episodes", ename), open = open)
  return(new_file)
}


#' @export
#' @rdname create_episode
create_episode_md <- function(title, make_prefix = FALSE, add = TRUE, path = ".", open = rlang::is_interactive()) {
  create_episode(title, ext = "md", make_prefix = make_prefix, add = add, path = path, open = open)
}

#' @export
#' @rdname create_episode
create_episode_rmd <- function(title, make_prefix = FALSE, add = TRUE, path = ".", open = rlang::is_interactive()) {
  create_episode(title, ext = "Rmd", make_prefix = make_prefix, add = add, path = path, open = open)
}

#' @export
#' @rdname create_episode
draft_episode_md <- function(title, make_prefix = FALSE, path = ".", open = rlang::is_interactive()) {
  create_episode(title, ext = "md", make_prefix = make_prefix, add = FALSE, path = path, open = open)
}

#' @export
#' @rdname create_episode
draft_episode_rmd <- function(title, make_prefix = FALSE, path = ".", open = rlang::is_interactive()) {
  create_episode(title, ext = "Rmd", make_prefix = make_prefix, add = FALSE, path = path, open = open)
}
