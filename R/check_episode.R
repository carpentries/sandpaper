#' @rdname check_lesson
#' @export
check_episode <- function(path) {
  episode_name <- fs::path_file(path)
  
  # Validation -----------------------------------------------------------------

  # Validators are stored in validators.R
  checklist <- list(
    validate_that(assertthat::has_extension(path, "Rmd")),
    validate_that(check_exists(fs::path_dir(path), episode_name)),
    validate_that(assertthat::is.readable(path))
    # Removed 2021-03-29 because we don't enforce numbered names 
    # validate_that(check_episode_name(path))

  )

  # Reporting ------------------------------------------------------------------
  report_validation(
    checklist,
    paste0("There were errors with the episode titled '", episode_name, "'.")
  )
  
}
