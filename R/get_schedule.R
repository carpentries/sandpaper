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
  yaml <- yaml::read_yaml(cfg)
  scd <- yaml[["schedule"]]
  if (is.null(scd)) {
    warning("No schedule set, using Rmd files in `episodes/` directory.\nTo remove this warning, define your schedule in `config.yaml` or use `set_schedule()` to generate it.")
    scd <- basename(get_source_files(path))
  }
  return(scd)
}
