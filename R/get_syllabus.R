#' Create a syllabus for the lesson
#'
#' This function is generally for internal use, but may be useful for those who
#' whish to automate creation of their own home pages.
#'
#' @param path the path to a lesson
#' @param questions if `TRUE`, the questions in the episodes will be added to
#'   the table. Defaults to `FALSE`.
#' @return a data frame containing the syllabus for the lesson with the timing,
#'   links, and questions associated
#' @keywords internal
#' @export
get_syllabus <- function(path = ".", questions = FALSE) {
  check_lesson(path)
   
  # The home page contains three things: 
  # 0. The main title as a header
  # 1. the content of index.md from the top level of the lesson directory.
  # 2. The computed syllabus
  #
  # The syllabus is a table containing timings, links, and questions associated
  # with each episode.
  
  # step 1: gather the episodes
  sched    <- get_schedule(path)
  episodes <- lapply(fs::path(path_episodes(path), sched), function(i) pegboard::Episode$new(i))
  
  # step 2: get the questions
  quest <- if (questions) vapply(episodes, get_questions, character(1)) else NULL

  # step 3: get yaml data
  timings <- vapply(episodes, get_timings, numeric(1))
  titles  <- vapply(episodes, get_titles, character(1))

  # step 4: get the paths
  paths <- fs::path(pkgdown::as_pkgdown(path_site(path))$dst_path, sched)
  paths <- fs::path_ext_set(paths, "html")
  
  start <- as.POSIXlt("00:00", format = "%H:%M", tz = "UTC")
  cumulative_minutes <- cumsum(timings)

  out <- data.frame(
    episode = titles, 
    timings = format(start + cumulative_minutes * 60L, "%H:%M"),
    path = paths,
    stringsAsFactors = FALSE
  )
  if (questions) {
    out$questions <- quest
  }
  return(out)
}

get_titles <- function(ep) {
  yml <- ep$get_yaml()
  yml$title
}


get_timings <- function(ep) {
  yml <- ep$get_yaml()
  as.numeric(sum(yml$teaching, yml$exercises, na.rm = TRUE))
}

get_questions <- function(ep) {
  # which filters out NA entries
  q <- ep$code[which(xml2::xml_attr(ep$code, "language") == "questions")]
  if (length(q) == 0) {
    q <- xml2::xml_find_all(
      ep$blocks, 
      ".//div[contains(@class, 'questions')] | .//section[contains(@class, 'questions')]"
    )
  }
  # low-tech solution: trim all of the \n#' -
  txt <- gsub("\n?#' ?-?", "\n", xml2::xml_text(q), perl = TRUE)
  txt <- gsub("\n{2,}", "\n", txt, perl = TRUE)
  trimws(txt)
}

