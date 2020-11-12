#' Clear the schedule in the lesson
#'
#' @param path path to the lesson
#'
#' @return NULL, invisibly
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_episodes(tmp) # produces warning
#' set_episodes(tmp, get_episodes(tmp), write = TRUE)
#' get_episodes(tmp) # no warning
#' reset_episodes(tmp)
#' get_episodes(tmp) # produces warning again because there is no schedule
reset_episodes <- function(path = ".") {
  # FIXME: This needs to change to reset_dropdown and friends.
  check_lesson(path)
  yaml <- get_config(path)
  copy_template("config", path, "config.yaml",
    values = list(
      title      = yaml$title,
      carpentry  = yaml$carpentry,
      life_cycle = yaml$life_cycle,
      license    = yaml$license,
      source     = yaml$source,
      branch     = yaml$branch,
      contact    = yaml$contact,
      NULL
    )
  )
  invisible(NULL)
}
