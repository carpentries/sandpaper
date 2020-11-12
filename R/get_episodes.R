#' Get the lesson schedule
#'
#' @param path the path to the lesson, defaults to the current working directory
#' @return a character vector of episodes in order of presentation
#'
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_episodes(tmp)
get_episodes <- function(path = ".") {
  cfg <- path_config(path)
  if (!fs::file_exists(cfg)) {
    stop("config file does not exist")
  }
  yaml <- yaml::read_yaml(cfg)
  scd <- yaml[["episodes"]] %||% yaml[["schedule"]]
  if (is.null(scd)) {
    warning("No schedule set, using Rmd files in `episodes/` directory.\nTo remove this warning, define your schedule in `config.yaml` or use `set_episodes()` to generate it.")
    scd <- basename(get_episode_sources(path))
  }
  return(scd)
}
