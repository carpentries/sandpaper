#' Move an episode in the schedule
#'
#' @param ep the name of a draft episode or the name/number of a published
#'   episode to move.
#' @param position the position in the schedule to move the episode. Valid
#'   positions are from 0 to the number of episodes (+1 for drafts). A value
#'   of 0 indicates that the episode should be removed from the schedule.
#' @param write defaults to `FALSE`, which will show the potential changes.
#'   If `TRUE`, the schedule will be modified and written to `config.yaml`
#' @param path the path to the lesson (defaults to the current working directory)
#' @seealso [create_episode()], [set_episodes()], [get_drafts()], [get_episodes()]
#' @examples
#' if (interactive() || Sys.getenv("CI") != "") {
#'   tmp <- tempfile()
#'   create_lesson(tmp)
#'   create_episode_md("getting-started", path = tmp)
#'   create_episode_rmd("plotting", path = tmp)
#'   create_episode_md("experimental", path = tmp, add = FALSE)
#'   set_episodes(tmp, c("getting-started.md", "introduction.Rmd", "plotting.Rmd"), 
#'     write = TRUE)
#'
#'   # Default episode order is alphabetical, we can use this to nudge episodes
#'   get_episodes(tmp)
#'   move_episode("introduction.Rmd", 1L, path = tmp) # by default, it shows you the change
#'   move_episode("introduction.Rmd", 1L, write = TRUE, path = tmp) # write the results
#'   get_episodes(tmp)
#' 
#'   # Add episodes from the drafts
#'   get_drafts(tmp)
#'   move_episode("experimental.md", 2L, path = tmp) # view where it will live
#'   move_episode("experimental.md", 2L, write = TRUE, path = tmp) 
#'   get_episodes(tmp)
#'
#'   # Unpublish episodes by setting position to zero
#'   move_episode("experimental.md", 0L, path = tmp) # view the results
#'   move_episode("experimental.md", 0L, write = TRUE, path = tmp)
#'   get_episodes(tmp)
#'
#'   # Interactively select the position where the episode should go by omitting
#'   # the position argument
#'   if (interactive()) {
#'     move_episode("experimental.md", path = tmp)
#'   }
#' }
move_episode <- function(ep = NULL, position = NULL, write = FALSE, path = ".") {
  eps <- get_episodes(path)
  drafts <- fs::path_file(get_sources(path, "episodes"))
  draft <- FALSE
  n <- length(eps)
  stopifnot(
    "can only move one episode at a time" = length(ep) == 1,
    "`ep` must be an episode or a draft index" = is.character(ep) || is.numeric(ep) && ep <= n && ep > 0
  )
  if (is.character(ep)) {
    if (ep %in% eps) {
      ins <- match(ep, eps)
    } else if (ep %in% drafts) {
      draft <- TRUE
      ins <- n + 1L
      n <- ins
    } else {
      stop(sprintf("There is no episode called '%s' in episodes or drafts", ep), call. = FALSE)
    }
  } else {
    ins <- ep
    ep <- eps[ins]
  }
  invalid <- function(pos) {
    !is.finite(pos) || (pos < 0 || pos > n)
  }
  #nocov start
  if (is.null(position)) {
    position <- -1L
    cli::cli_div()
    cli::cli_alert_info("Select a number to insert your episode")
    cli::cli_text("(if an episode already occupies that position, it will be shifted down)") 
    cli::cli_text()
    choices <- if (draft) c(eps, "[insert at end]") else eps
    cli::cli_ol(choices)
    cli::cli_text()
    cli::cli_div()
    while (invalid(position)) {
      position <- suppressWarnings(as.integer(readline("Choice: ")))
    }
  }
  #nocov end
  if (invalid(position)) {
    stop(glue::glue("Can not move an episode to position {position}, it is out of bounds."), call. = FALSE)
  }
  eps <- eps[-ins]
  n <- length(eps)
  if (position == 0) {
    first <- seq(n)
    last <- 0L
    ep <- character(0)
  } else if (position == 1L) {
    first <- 0L
    last <- seq(n)
  } else if (position == n + 1L) {
    first <- seq(n)
    last <- 0L
  } else {
    first <- seq(position - 1L)
    last <- seq(position, n)
  }
  new <- c(eps[first], ep, eps[last])
  set_episodes(path = path, order = new, write = write)
}
