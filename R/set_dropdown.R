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
#' create_lesson(tmp, "test lesson")
#' # Change the title and License
#' set_config(key = c("title", "license"), 
#'   value = c("Absolutely Free Lesson", "CC0"),
#'   path = tmp,
#'   write = TRUE
#' )
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
  real_files <- fs::path_file(fs::dir_ls(
    fs::path(path, folder), 
    type = "file", 
    regexp = "[.]R?md"
  ))
  if (any(!order %in% real_files)) {
    error_missing_config(order, real_files, folder)
  }
  yaml  <- quote_config_items(get_config(path))
  sched <- yaml[[folder]]
  sched <- if (is.null(sched) && folder == "episodes") yaml[["schedule"]] else sched
  sched_folders <- c("episodes", "learners", "instructors", "profiles")
  if (folder %in% sched_folders) {
    # strip the extension
    yaml[[folder]] <- fs::path_file(order)
  } else {
    yaml[[folder]] <- order
  }
  if (write) {
    # Avoid whisker from interpreting the list incorrectly.
    for (i in sched_folders) {
      yaml[[i]] <- yaml_list(yaml[[i]])
    }
    copy_template("config", path, "config.yaml", values = yaml)
  } else {
    show_changed_yaml(sched, order, yaml, folder)
  }
  invisible()
}

#' @param key the key for a vector of parameters
#' @param value the value matching each key
#' @export
#' @rdname set_dropdown
set_config <- function(key = NULL, value = NULL, path = ".", write = FALSE) {
  stopifnot(
    "key must not be null" = length(key) > 0,
    "value must not be null" = length(value) > 0,
    "number of keys and values must be equal" = length(key) == length(value)
  )
  cfg <- path_config(path)
  l <- readLines(cfg)
  what <- purrr::map_int(glue::glue("^{key}:"), grep, l)
  line <- glue::glue("{key}: {shQuote(value)}")
  if (write) {
    cli::cli_alert_info("Writing to {.file {cfg}}")
    purrr::walk2(l[what], line, ~cli::cli_alert("{.code {.x} -> {.y}}"))
    l[what] <- line
    writeLines(l, cfg)
  } else {
    the_call <- match.call()
    thm <- cli::cli_div(theme = sandpaper_cli_theme())
    on.exit(cli::cli_end(thm))
    purrr::walk2(l[what], line, ~{
      cli::cli_text(c(cli::col_cyan("- "), cli::style_blurred(.x)))
      cli::cli_text(c(cli::col_yellow("+ "), .y))
    })
    the_call[["write"]] <- TRUE
    cll <- paste(capture.output(cll), collapse = "\n")
    cli::cli_alert_info("To save this configuration, use\n{.code {cll}}")
    return(the_call)
  }
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

