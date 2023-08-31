#' Build your lesson and work on it at the same time
#'
#' This function will serve your lesson and it will auto-update whenever you
#' save a file.
#'
#' @param path the path to your lesson. Defaults to the current path.
#' @param quiet if `TRUE`, then no messages are printed to the output. Defaults
#'   to `FALSE` in non-interactive sessions, which allows messages to be
#'   printed.
#' @param ... options passed on to [servr::server_config()] by way of
#'   [servr::httw()]. These can include **port** and **host** configuration.
#' @return the output of [servr::httw()], invisibly. This is mainly used for its
#'   side-effect
#'
#' @details
#' `sandpaper::serve()` is an entry point to working on any lesson using The
#' Carpentries Workbench. When you run this function interactively, a preview
#' window will open either in RStudio or your browser with an address like
#' `localhost:4321` (note the number will likely be different). When you make
#' changes to files in your lesson, this preview will update automatically.
#'
#' When you are done with the preview, you can run `servr::daemon_stop()`.
#'
#' ## Command line usage
#'
#' You can use this on the command line if you do not use RStudio or another
#' IDE that acts as a web browser. To run this on the command line, use:
#'
#' ```bash
#' R -e 'sandpaper::serve()'
#' ```
#'
#' Note that unlike an interactive session, progress messages are not printed
#' (except for the accessibility checks) and the browser window will not
#' automatically launch. You can have these messages print to screen with the
#' `quiet = FALSE` argument. In addition, If you want to specify a port and
#' host for this function, you can do so using the port and host arguments:
#'
#' ```bash
#' R -e 'sandpaper::serve(quiet = FALSE, host = "127.0.0.1", port = "3435")'
#' ```
#'
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
#'  #
#'  # to stop the server, run
#'  servr::daemon_stop()
#'  #
#'  # If you want to use a different port, you can specify it directly
#'  sandpaper::serve(host = "127.0.0.1", port = "3435")
#' }
#nocov start
# Note: we can not test this in covr because I'm not entirely sure of how to get
#       it going
serve <- function(path = ".", quiet = !interactive(), ...) {
  this_path <- root_path(path)
  rend <- function(file_list = this_path) {
    if (any(fs::is_file(file_list))) {
      file_list <- file_list[endsWith(file_list, "md")]
      if (length(file_list) == 0L) {
        file_list <- this_path
      }
    }
    for (f in file_list) {
      message("BUILDING", f, "-----------------------------------")
      build_lesson(f, preview = FALSE, quiet = quiet)
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
      return(x[(!startsWith(x, no_site) | !startsWith(x, no_git))])
    }
  }
  this_filter <- make_filter(this_path)
  # to start, build the site and then watch things:
  rend(this_path)
  servr::httw(prod, watch = this_path, filter = this_filter, handler = rend,
    ...)
}
#nocov end
