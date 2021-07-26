#' Helpers to extract contents of dropdown menus on the site
#'
#' This fuction will extract the resources that exist and are listed in the
#' config file.
#'
#' @param path the path to the lesson, defaults to the current working directory
#' @param folder the folder to extract fromt he dropdown menues
#' @param trim if `TRUE` (default), only the file name will be presented. When
#'   `FALSE`, the full path will be prepended.
#' @return a character vector of episodes in order of presentation
#'
#' @export
#' @rdname get_dropdown
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' get_episodes(tmp)
#' get_learners(tmp) # information for learners
get_dropdown <- function(path = ".", folder, trim = TRUE) {
  as.character(get_resource_list(path, trim, folder, warn = TRUE))
}

#' @rdname get_dropdown
#' @export
get_episodes <- function(path = ".", trim = TRUE) {
  as.character(get_resource_list(path, trim, "episodes", warn = TRUE))
}

#' @rdname get_dropdown
#' @export
get_learners <- function(path = ".", trim = TRUE) {
  as.character(get_resource_list(path, trim, "learners", warn = TRUE))
}

#' @rdname get_dropdown
#' @export
get_instructors <- function(path = ".", trim = TRUE) {
  as.character(get_resource_list(path, trim, "instructors", warn = TRUE))
}

#' @rdname get_dropdown
#' @export
get_profiles <- function(path = ".", trim = TRUE) {
  as.character(get_resource_list(path, trim, "profiles", warn = TRUE))
}

