#' Clear the schedule in the lesson
#'
#' @param path path to the lesson
#'
#' @return NULL, invisibly
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE, rmd = FALSE)
#' get_episodes(tmp) # produces warning
#' set_episodes(tmp, get_episodes(tmp), write = TRUE)
#' get_episodes(tmp) # no warning
#' reset_episodes(tmp)
#' get_episodes(tmp) # produces warning again because there is no schedule
reset_episodes <- function(path = ".") {
  # FIXME: This needs to change to reset_dropdown and friends.
  check_lesson(path)
  yaml <- quote_config_items(get_config(path))
  copy_template("config", path, "config.yaml",
    values = yaml[names(yaml) != "episodes"])
  invisible(NULL)
}
