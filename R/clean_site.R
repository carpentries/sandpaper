#' Remove all files associated with the site
#'
#' Use this if you want to rebuild your site from scratch.
#' 
#' @param path the path to the site
#'
#' @export
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp)
#' build_lesson(tmp, preview = FALSE)
#' dir(file.path(tmp, "site"))
#' clear_site(tmp)
#' dir(file.path(tmp, "site"))
clear_site <- function(path = ".") {
  check_lesson(path)
  fs::dir_delete(path_site(path))
  fs::dir_create(path_site(path))
  create_site_readme(path)
}
