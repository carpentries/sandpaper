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
#' if (rmarkdown::pandoc_available("2.11"))
#'   build_lesson(tmp, preview = FALSE)
#' dir(file.path(tmp, "site"))
#' reset_site(tmp)
#' dir(file.path(tmp, "site"))
reset_site <- function(path = ".") {
  check_lesson(path)
  fs::dir_delete(path_site(path))
  create_site(path)
}
