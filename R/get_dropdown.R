#' Get the contents of a dropdown on the site
#'
#' @param path the path to the lesson, defaults to the current working directory
#' @param folder the name of the folder containing the dropdown items
#' @return a character vector of episodes in order of presentation
#'
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_episodes(tmp)
#' get_learners(tmp) # information for learners
get_dropdown <- function(path = ".", folder) {
  cfg <- path_config(path)
  if (!fs::file_exists(cfg)) {
    stop("config file does not exist")
  }
  episode <- folder == "episodes"
  yaml <- yaml::read_yaml(cfg)
  scd <- yaml[[folder]]
  scd <- if (episode && is.null(scd)) yaml[["schedule"]] else scd
  if (is.null(scd)) {
    if (episode) warn_schedule()
    scd <- basename(get_sources(path, folder))
  }
  return(scd)
}

#' @rdname get_dropdown
#' @export
get_episodes <- function(path = ".") {
  get_dropdown(path, "episodes")
}

#' @rdname get_dropdown
#' @export
get_learners <- function(path = ".") {
  get_dropdown(path, "learners")
}

#' @rdname get_dropdown
#' @export
get_instructors <- function(path = ".") {
  get_dropdown(path, "instructors")
}

#' @rdname get_dropdown
#' @export
get_profiles <- function(path = ".") {
  get_dropdown(path, "profiles")
}

warn_schedule <- function() {
  msg <- "No schedule set, using Rmd files in `episodes/` directory."
  msg <- paste0(msg, "\n", "To remove this warning, define your schedule in ")
  msg <- paste0(msg, "`config.yaml` or use `set_episodes()` to generate it.")
  warning(msg)
}
