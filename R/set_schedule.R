#' Set the schedule for the lesson
#'
#' @param path path to the lesson
#' @param order the episodes in the order presented (with extension)
#' @param write if `TRUE`, the schedule will overwrite the schedule in the
#'   current file. 
#'
#' @export
#' @examples
#'
#' tmp <- tempfile()
#' create_lesson(tmp)
#' create_episode("using-R", path = tmp)
#' print(sched <- get_schedule(tmp))
#' 
#' # reverse the schedule
#' set_schedule(tmp, order = rev(sched))
#' # write it
#' set_schedule(tmp, order = rev(sched), write = TRUE)
#'
#' # see it
#' get_schedule(tmp)
#'
set_schedule <- function(path, order = NULL, write = FALSE) {
  if (is.null(order)) {
    stop("schedule must have an order")
  }
  yml <- get_config(path)
  yml$schedule <- order

  if (write) {
    yaml_writer(yml, path_config(path))
  } else {
    cat(yaml::as.yaml(yml))
  }
  invisible(yml)
}
#' Create the episode schedule for the lesson
#'
#' Note: this is not a public-facing function
#'
#' This will create a schedule in the `config.yml` file for the episodes in the
#' `episodes/` directory. By default, it will use alphabetical order, but you
#' can rearrange the episodes in the `config.yml` file manually. The `config.yml`
#' file will be the source of truth for building the site, so creating the
#' schedule in that file is important.
#'
#' @param path path to your lesson
#' @param write if `TRUE`, the modified schedule will be written to your config
#'   file. Defaults to `FALSE`.
#'
#' @return NULL, invisibly. This is used for the side-effect of modifying the
#' `config.yml` file.
#'
#' @keywords internal
update_schedule <- function(path) {

  current  <- get_schedule(path)
  # episode slug
  episodes <- fs::path_file(get_source_files(path))
  
  matching <- episodes %in% current # returns FALSE if there are none in common
  new      <- episodes[!matching]
  set_schedule(path, order = c(current, new), write = TRUE)
}

