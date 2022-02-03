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
# Note: we can not test this in covr because I'm not entirely sure of how to get
#       it going
serve <- function(path = ".") {
  path <- root_path(path)
  rend <- function(file_list = ".") {
    for (f in file_list) {
      build_lesson(f, preview = FALSE)
    }
  }
  # path to the production folder that {servr} needs to render
  prod <- fs::path(path_site(path), "docs") 
  # filter function generator for {servr} to exclude the site folder
  #
  # This assumes that the input to the function will be whole file names
  # which is the output of list.files() with recurse = TRUE and
  # full.names = TRUE
  #
  # @param base the base path
  make_filter <- function(base = path) {
    no_site <- file.path(base, "site")
    no_git  <- file.paths(base, ".git")
    # return a filter function for the files
    function(x) x[!startsWith(x, no_site) | !startsWith(x, no_git)]
  }
  # to start, build the site and then watch things:
  rend()
  servr::httw(prod, watch = path, filter = make_filter(path), handler = rend)
}
#nocov end
