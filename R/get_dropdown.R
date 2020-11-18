#' Get the contents of a dropdown on the site
#'
#' @param path the path to the lesson, defaults to the current working directory
#' @param folder the name of the folder containing the dropdown items
#' @param trim if `TRUE` (default), only the file name will be presented. When
#'   `FALSE`, the full path will be prepended.
#' @return a character vector of episodes in order of presentation
#'
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_episodes(tmp)
#' get_learners(tmp) # information for learners
get_dropdown <- function(path = ".", folder, trim = TRUE) {
  cfg <- path_config(path)
  if (!fs::file_exists(cfg)) {
    stop("config file does not exist")
  }
  episode <- folder == "episodes"
  yaml <- yaml::read_yaml(cfg)
  scd <- yaml[[folder]]
  scd <- if (episode && is.null(scd)) yaml[["schedule"]] else scd
  unset <- is.null(scd)
  # Return early if we only want the defined schedule
  if (!unset && trim) {
    return(scd)
  }
  # If the resources are unset in the yaml, get the sources
  if (unset) {
    if (episode) warn_schedule()
    scd <- get_sources(path, folder)
  # If they are set, make sure they are in the right order.
  } else {
    src <- get_sources(path, folder)
    scd <- src[match(scd, basename(src))]
  } 
  if (trim) basename(scd) else scd
}

#' @rdname get_dropdown
#' @export
get_episodes <- function(path = ".", trim = TRUE) {
  get_dropdown(path, "episodes", trim)
}

#' @rdname get_dropdown
#' @export
get_learners <- function(path = ".", trim = TRUE) {
  get_dropdown(path, "learners", trim)
}

#' @rdname get_dropdown
#' @export
get_instructors <- function(path = ".", trim = TRUE) {
  get_dropdown(path, "instructors", trim)
}

#' @rdname get_dropdown
#' @export
get_profiles <- function(path = ".", trim = TRUE) {
  get_dropdown(path, "profiles", trim)
}

warn_schedule <- function() {
  msg <- "No schedule set, using Rmd files in `episodes/` directory."
  msg <- paste0(msg, "\n", "To remove this warning, define your schedule in ")
  msg <- paste0(msg, "`config.yaml` or use `set_episodes()` to generate it.")
  warning(msg)
}
