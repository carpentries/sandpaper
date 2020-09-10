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
  yml <- get_config(path)
  copy_template("config", path, "config.yml",
    values = list(
      title      = yml$title,
      carpentry  = yml$carpentry,
      life_cycle = yml$life_cycle,
      license    = yml$license,
      source     = yml$source,
      branch     = yml$branch,
      contact    = yml$contact,
      NULL
    )
  )
  invisible(NULL)
}
