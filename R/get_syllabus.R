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

  # The home page contains three things:
  # 0. The main title as a header
  # 1. the content of index.md from the top level of the lesson directory
  # 2. The computed syllabus
  #
  # The syllabus is a table containing timings, links, and questions associated
  # with each episode.
  this_lesson(path)
  if (!is.null(instructor_globals$get()$syllabus)) {
    return(instructor_globals$get()$syllabus)
  }
  sched <- .resources$get()[["episodes"]] %||%
    get_resource_list(path, trim = TRUE, subfolder = "episodes")

  create_syllabus(sched, this_lesson(path), path, questions)
}

create_syllabus <- function(episodes, lesson, path, questions = TRUE) {
  if (is.null(episodes)) {
    out <- data.frame(
      episode = character(0),
      timings = character(0),
      path = character(0),
      percents = character(0),
      stringsAsFactors = FALSE
    )
    return(out)
  }
  sched <- fs::path_file(episodes)
  # We have to invalidate the cache if the syllabus is mis-matched
  cache_invalid <- !setequal(sched, names(lesson$episodes))
  if (cache_invalid) {
    lesson <- set_this_lesson(path)
  }
  episodes <- lesson$episodes[sched]

  quest <- if (questions) vapply(episodes, get_questions, character(1)) else NULL

  timings <- vapply(episodes, get_timings, numeric(1))
  titles  <- vapply(episodes, get_titles, character(1))

  # NOTE: This assumes a flat file structure for the website.
  paths <- fs::path_ext_set(sched, "html")

  start <- as.POSIXlt("00:00", format = "%H:%M", tz = "UTC")
  # Note: we are creating a start time of 0 and adding "Finish" to the end.
  if (any(timings < 0)) {
    bad <- which(timings < 0)
    msg <- c("There are missing timings from {length(bad)} episode{?s}.",
      "*" = "{.file {sched[bad]}}",
      "i" = "The default value of {.emph 5 minutes} will be used for teaching and exercises.")
    cli::cli_warn(msg)
  }
  cumulative_minutes <- cumsum(c(0, abs(timings))) * 60L

  out <- data.frame(
    episode = c(titles, "Finish"),
    timings = format(start + cumulative_minutes, "%Hh %Mm"),
    path = c(paths, ""),
    percents = sprintf("%1.0f", 100 * (cumulative_minutes / max(cumulative_minutes))),
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
  coerce_integer <- function(i, default = -5L) {
    not_integer <- !grepl("^[0-9]+$", i)
    # NULL will return logical(0)
    if (length(not_integer) == 0 || not_integer) {
      i <- default
    }
    return(as.integer(i))
  }
  times <- c(coerce_integer(yaml$teaching), coerce_integer(yaml$exercises), coerce_integer(yaml[["break"]], 0L))
  signs <- any(times < 0)
  res <- as.integer(sum(abs(times), na.rm = TRUE))
  if (signs) {
    -res
  } else {
    res
  }
}

get_questions <- function(ep) {
  paste(ep$questions, collapse = "\n")
}

