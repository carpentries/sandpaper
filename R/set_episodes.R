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
#' print(sched <- get_episodes(tmp))
#' 
#' # reverse the schedule
#' set_episodes(tmp, order = rev(sched))
#' # write it
#' set_episodes(tmp, order = rev(sched), write = TRUE)
#'
#' # see it
#' get_episodes(tmp)
#'
set_episodes <- function(path, order = NULL, write = FALSE) {
  if (is.null(order)) {
    stop("schedule must have an order")
  }
  yaml  <- get_config(path)
  sched <- yaml[["episodes"]] %||% yaml[["schedule"]]
  yaml[["episodes"]]<- if (length(order) == 1L) list(order) else order

  if (write) {
    # Soooooo writing yaml with comments is a non-trivial issue for the {yaml}
    # package, but we want to retain our comments if an author uses this 
    # interface to update the yaml. The best we can do at the moment is to use
    # the template.... but this will be superseded at the moment if we decide to
    # change around the order :grimace:
    copy_template("config", path, "config.yaml",
      values = list(
        title       = yaml$title,
        carpentry   = yaml$carpentry,
        life_cycle  = yaml$life_cycle,
        license     = yaml$license,
        source      = yaml$source,
        branch      = yaml$branch,
        contact     = yaml$contact,
        episodes    = paste0('\n', yaml::as.yaml(yaml[['episodes']])),
        learners    = yaml$learners,
        instructors = yaml$instructors,
        profiles    = yaml$profiles,
        NULL
      )
    )
  } else {
    if (requireNamespace("cli", quietly = TRUE)) {
      # display for the user to distinguish what was added and what was taken 
      removed <- sched %nin% order
      added   <- order %nin% sched
      order[added] <- cli::style_bold(cli::col_green(order[added]))
      cli::cat_line(yaml::as.yaml(yaml[names(yaml) != "episodes"]), col = "silver")
      cli::cat_line("episodes:")
      cli::cat_bullet(order, bullet = "line")
      if (any(removed)) {
        cli::cli_rule("Removed episodes")
        cli::cat_bullet(sched[removed], bullet = "cross", bullet_col = "red")
      }
    } else {
      cat(yaml::as.yaml(yaml))
    }
  }
  invisible()
}

