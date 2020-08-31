#' Get the lesson schedule
#'
#' @param path the path to the lesson
#' @return a character vector of episodes in order of presentation
#'
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_schedule(tmp)
get_schedule <- function(path) {
  cfg <- path_config(path)
  if (!fs::file_exists(cfg)) {
    stop("config file does not exist")
  }
  yml <- yaml::read_yaml(cfg)
  scd <- yml[["schedule"]]
  if (is.null(scd)) {
    return(NULL)
  }
  return(scd)
  # This is if I want to redo how I set up the config 
  paths <- vapply(scd, '[[', character(1), 'episode')
  slugs <- vapply(scd, '[[', character(1), 'name')
  names(paths) <- slugs
  paths
}
