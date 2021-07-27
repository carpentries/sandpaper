#' Create a syllabus for the lesson
#'
#' This function is generally for internal use, but may be useful for those who
#' whish to automate creation of their own home pages.
#'
#' @param path the path to a lesson
#' @param questions if `TRUE`, the questions in the episodes will be added to
#'   the table. Defaults to `FALSE`.
#' @param use_built if `TRUE` (default), the rendered episodes will be used to
#'   generate the syllabus
#' @return a data frame containing the syllabus for the lesson with the timing,
#'   links, and questions associated
#' @keywords internal
#' @export
get_syllabus <- function(path = ".", questions = FALSE, use_built = TRUE) {
  check_lesson(path)
   
  # The home page contains three things: 
  # 0. The main title as a header
  # 1. the content of index.md from the top level of the lesson directory
  # 2. The computed syllabus
  #
  # The syllabus is a table containing timings, links, and questions associated
  # with each episode.
  
  sched    <- get_resource_list(path, trim = TRUE, subfolder = "episodes")
  lesson   <- pegboard::Lesson$new(path, jekyll = FALSE, fix_links = FALSE)
  episodes <- lesson$episodes[sched]
  
  quest <- if (questions) vapply(episodes, get_questions, character(1)) else NULL

  timings <- vapply(episodes, get_timings, numeric(1))
  titles  <- vapply(episodes, get_titles, character(1))

  paths <- fs::path(pkgdown::as_pkgdown(path_site(path))$dst_path, sched)
  paths <- fs::path_ext_set(paths, "html")
  
  start <- as.POSIXlt("00:00", format = "%H:%M", tz = "UTC")
  # Note: we are creating a start time of 0 and adding "Finish" to the end.
  cumulative_minutes <- cumsum(c(0, timings))

  out <- data.frame(
    episode = c(titles, "Finish"), 
    timings = format(start + cumulative_minutes * 60L, "%H:%M"),
    path = c(paths, ""),
    stringsAsFactors = FALSE
  )
  if (questions) {
    out$questions <- c(quest, "")
  }
  return(out)
}

get_titles <- function(ep) {
  yaml <- ep$get_yaml()
  yaml$title
}

get_timings <- function(ep) {
  yaml <- ep$get_yaml()
  as.numeric(sum(yaml$teaching, yaml$exercises, na.rm = TRUE))
}

get_questions <- function(ep) {
  paste(ep$questions, collapse = "\n")
}

