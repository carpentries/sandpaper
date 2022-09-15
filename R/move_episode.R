#' Move an episode in the schedule
#'
#' If you need to move a single episode, this function gives you a programmatic
#' or interactive interface to accomplishing this task, whether you need to add
#' and episode, draft, or remove an episode from the schedule.
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
#' @export
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
  if (length(ep) != 1) {
    cli::cli_alert_danger("Too many episodes specified: {ep}. {.fn move_episode} can only move one episode at a time.")
    stop("parameter `ep` must be a single file name or position", call. = FALSE)
  }
  ep_is_char <- is.character(ep)
  if (!ep_is_char) {
    if (is.numeric(ep) && (ep > n || ep < 0)) {
      cli::cli_alert_danger("Episode index {ep} is out of range (0--{n}). {.fn move_episode} can only move existing files.")
      stop("`ep` must be an episode index if it is numeric.")
    }
    if (!is.numeric(ep)) {
      cli::cli_alert_danger("'{ep}' does not refer to any episode. {.fn move_episode} can only move existing files.")
      stop("`ep` must be an episode name or index.")
    }
  }
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
  if (is.null(position)) {
    position <- user_find_position(eps, draft)
  }
  if (!is.finite(position) || (position < 0 || position > n)) {
    stop(glue::glue("Can not move an episode to position {position}, it is out of bounds."), call. = FALSE)
  } else {
    # if the position is `TRUE`, then we assume it is being added to the end of
    # the episode list, otherwise, it remains unchanged. a value of `FALSE` will
    # be coerced to 0L.
    position <- if (isTRUE(position)) n else position
  }
  
  eps <- eps[-ins]
  n <- length(eps)
  if (n == 0) {
    # this is the first episode being added!
    return(set_episodes(path = path, order = ep, write = write))
  }
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

#' Have user select position for an episode from a list
#'
#' This function is interactive at the while loop where it will check if the 
#' position element is finite (failing on anything that can not be coerced to
#' an integer) and if it is in bounds. It will repeat until a correct choice has
#' been selected.
#' 
#' For testing, it will return -1 and trigger an error in `move_episode()`
#'
#' @param eps a vector of episode names
#' @param draft if `TRUE`, the number of choices will be the number of episodes
#'   plus a space at the end to insert the new episode.
#' @noRd
user_find_position <- function(eps, draft = FALSE) {
  has_user <- interactive() && !identical(Sys.getenv("TESTTHAT"), "true")
  position <- -1L
  cli::cli_div()
  cli::cli_alert_info("Select a number to insert your episode")
  cli::cli_text("(if an episode already occupies that position, it will be shifted down)") 
  cli::cli_text()
  choices <- if (draft) c(eps, "[insert at end]") else eps
  n <- length(choices)
  cli::cli_ol(choices)
  cli::cli_text()
  cli::cli_div()
  #nocov start
  while (has_user && (!is.finite(position) || (position < 0 || position > n))) {
    position <- suppressWarnings(as.integer(readline("Choice: ")))
  }
  #nocov end
  position
}

#' This will strip existing episode prefixes and set the schedule
#'
#' Episode order for Carpentries lessons originally used a strategy of prefixing
#' files by a two-digit number to force a specific order by filename. This
#' function will strip these numbers from the filename and set the schedule
#' according to the original order.
#' 
#' @inheritParams move_episode
#' @return when `write = TRUE`, the modified list of episodes. When 
#'  `write = FALSE`, the modified call is returned.
#'
#' @note git will recognise this as deleting a file and then adding a new file
#'   in the stage. If you run `git add`, it should recognise that it is a rename.
#' 
#' @export
#' @seealso [create_episode()] for creating new episodes, [move_episode()] for
#'   moving individual episodes around.
#'
#' @examples
#' if (FALSE) {
#'   strip_prefix() # test if the function is doing what you want it to do
#'   strip_prefix(write = TRUE) # rewrite the episode names
#' }
strip_prefix <- function(path = ".", write = FALSE) {
  path <- root_path(path)
  episodes <- get_episodes(path)
  suppressWarnings(prefix <- as.integer(sub("^([0-9]{2}).+$", "\\1", episodes)))
  no_prefix <- length(prefix) == 0 || all(is.na(prefix))
  if (no_prefix) {
    cli::cli_alert_info("No prefix detected... nothing to do")
    return(episodes)
  }
  epathodes <- path_episodes(path)
  all_episodes <- fs::path_file(fs::dir_ls(epathodes, regexp = "*.[Rr]?md"))
  scheduled_episodes <- all_episodes[all_episodes %in% episodes]
  moved_episodes <- sub("^[0-9]{2}(\\.[0-9]+)?[-]", "", scheduled_episodes, perl = TRUE)
  if (write) {
    fs::file_move(fs::path(epathodes, scheduled_episodes), 
      fs::path(epathodes, moved_episodes))
    return(set_episodes(path = path, order = moved_episodes, write = TRUE))
  } else {
    the_call <- match.call()
    thm <- cli::cli_div(theme = sandpaper_cli_theme())
    on.exit(cli::cli_end(thm))
    cli::cli_alert_info("Stripped prefixes")
    cli::cli_ol()
    for (i in seq(moved_episodes)) {
      cli::cli_li("{.file {scheduled_episodes[i]}}\t->\t{.file {moved_episodes[i]}}")
    }
    the_call[["write"]] <- TRUE
    cll <- gsub("\\s+", " ", paste(utils::capture.output(the_call), collapse = ""))
    cli::cli_rule()
    cli::cli_alert_info("To save this configuration, use\n\n{.code {cll}}")
    return(invisible(the_call))
  }
}
