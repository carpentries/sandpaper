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
  sched <- yml$schedule
  yml$schedule <- if (length(order) == 1L) list(order) else order

  if (write) {
    copy_template("config", path, "config.yml",
      values = list(
        title      = yml$title,
        carpentry  = yml$carpentry,
        life_cycle = yml$life_cycle,
        license    = yml$license,
        source     = yml$source,
        branch     = yml$branch,
        contact    = yml$contact,
        schedule   = paste0('\n', yaml::as.yaml(yml[['schedule']])),
        NULL
      )
    )
  } else {
    if (requireNamespace("cli", quietly = TRUE)) {
      # display for the user to distinguish what was added and what was taken 
      removed <- sched %nin% order
      added   <- order %nin% sched
      order[added] <- cli::style_bold(cli::col_green(order[added]))
      cli::cat_line(yaml::as.yaml(yml[names(yml) != "schedule"]), col = "silver")
      cli::cat_line("schedule:")
      cli::cat_bullet(order, bullet = "line")
      if (any(removed)) {
        cli::cli_rule("Removed episodes")
        cli::cat_bullet(sched[removed], bullet = "cross", bullet_col = "red")
      }
    } else {
      cat(yaml::as.yaml(yml))
    }
  }
  invisible()
}

