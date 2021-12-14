#' Build your lesson and work on it at the same time
#'
#' This function will serve your lesson and it will auto-update whenever you
#' save a file. s
#'
#' @param path the path to your lesson. Defaults to the current path.
#' @return the output of `servr::httw()`, invisibly. This is mainly used for its
#'   side-effect
#' @export
#' @examples
#' if (FALSE) {
#'  # create an example lesson 
#'  tmp <- tempfile()
#'  create_lesson(tmp, open = FALSE)
#'  
#'  # open the episode for editing
#'  file.edit(fs::path(tmp, "episodes", "01-introduction.Rmd"))
#'
#'  # serve the lesson and begin editing the file. Watch how the file will
#'  # auto-update whenever you save it. 
#'  sandpaper::serve()
#' }
#nocov start
serve <- function(path = ".") {
  path <- root_path(path)
  rend <- function(file_list = ".") {
    for (f in file_list) {
      build_lesson(f, preview = FALSE)
    }
  }
  rend()
  servr::httw(fs::path(path_site(path), "docs"), watch = path, handler = rend)
}
#nocov end
