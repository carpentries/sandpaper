#' Clear the schedule in the lesson
#'
#' @param path path to the lesson
#'
#' @return NULL, invisibly
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_schedule(tmp) # produces warning
#' set_schedule(tmp, get_schedule(tmp), write = TRUE)
#' get_schedule(tmp) # no warning
#' clear_schedule(tmp)
#' get_schedule(tmp) # produces warning again because there is no schedule
clear_schedule <- function(path = ".") {
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
