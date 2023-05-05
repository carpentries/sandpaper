#' Build your lesson and work on it at the same time
#'
#' This function will serve your lesson and it will auto-update whenever you
#' save a file.
#'
#' @param path the path to your lesson. Defaults to the current path.
#' @return the output of `servr::httw()`, invisibly. This is mainly used for its
#'   side-effect
#'
#'
#' @details
#' `sandpaper::serve()` is an entry point to working on any lesson using The
#' Carpentries Workbench. When you run this function, a preview window will
#' open either in RStudio or your browser with an address like `localhost:4213`
#' (note the number will likely be different). When you make changes to files
#' in your lesson, this preview will update automatically.
#'
#' When you are done with the preview, you can run `servr::daemon_stop()`.
#'
#' @export
#' @seealso [build_lesson()], render the lesson once, locally.
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
  this_path <- root_path(path)
  rend <- function(file_list = this_path) {
    for (f in file_list) {
      build_lesson(f, preview = FALSE)
    }
  }
  # path to the production folder that {servr} needs to render
  prod <- fs::path(path_site(this_path), "docs")
  # filter function generator for {servr} to exclude the site folder
  #
  # This assumes that the input to the function will be whole file names
  # which is the output of list.files() with recurse = TRUE an
  # full.names = TRUE
  #
  # @param base the base path
  make_filter <- function(base = this_path) {
    no_site <- file.path(base, "site")
    no_git  <- file.path(base, ".git")
    # return a filter function for the files
    function(x) {
      x[!startsWith(x, no_site) | !startsWith(x, no_git)]
    }
  }
  this_filter <- make_filter(this_path)
  # to start, build the site and then watch things:
  rend(this_path)
  servr::httw(prod, watch = this_path, filter = this_filter, handler = rend)
}
#nocov end
