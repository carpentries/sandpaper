#' Get the configuration parameters for the lesson
#'
#' @param path path to the lesson
#' @return a yaml list
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_config(tmp)
get_config <- function(path) {
  cfg <- path_config(path)
  if (!fs::file_exists(cfg)) {
    stop("config file does not exist")
  }
  yaml::read_yaml(cfg)
}
