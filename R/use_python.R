#' Use Python
#'
#' Associate a version of Python with your lesson. This is essentially a wrapper
#' around [renv::use_python()].
#'
#' @param path path to the current project
#' @inheritParams renv::use_python
#' @param ... Further arguments to be passed on to [renv::use_python()]
#'
#' @export
#' @seealso [renv::use_python()]
#' @return The path to the Python executable. Note that this function is mainly
#'   called for its side effects.
use_python <- function(path = ".", python = NULL,
                       type = c("auto", "virtualenv", "conda", "system"), ...) {

  renv::load(project = path)
  on.exit({
    invisible(utils::capture.output(renv::deactivate(project = path), type = "message"))
  }, add = TRUE)
  renv::use_python(python = python, type = type, ...)
}

