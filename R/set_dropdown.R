#' Set the order of items in a dropdown menu
#'
#' @param path path to the lesson. Defaults to the current directory.
#' @param order the files in the order presented (with extension)
#' @param write if `TRUE`, the schedule will overwrite the schedule in the
#'   current file. 
#' @param folder one of four folders that sandpaper recognises where the files
#'   listed in `order` are located: episodes, learners, instructors, profiles.
#'
#' @export
#' @rdname set_dropdown
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
set_dropdown <- function(path = ".", order = NULL, write = FALSE, folder) {
  check_order(order, folder)
  yaml  <- get_config(path)
  sched <- yaml[[folder]] 
  sched <- if (is.null(sched) && folder == "episodes") yaml[["schedule"]] else sched
  yaml[[folder]] <- fs::path_file(order)
  if (write) {
    # Avoid whisker from interpreting the list incorrectly.
    for (i in c("episodes", "learners", "instructors", "profiles")) {
      yaml[[i]] <- yaml_list(yaml[[i]])
    }
    copy_template("config", path, "config.yaml", values = yaml)
  } else {
    show_changed_yaml(sched, order, yaml, folder)
  }
  invisible()
}

#' @export
#' @rdname set_dropdown
set_episodes <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "episodes")
}

#' @export
#' @rdname set_dropdown
set_learners <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "learners")
}

#' @export
#' @rdname set_dropdown
set_instructors <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "instructors")
}

#' @export
#' @rdname set_dropdown
set_profiles <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "profiles")
}

