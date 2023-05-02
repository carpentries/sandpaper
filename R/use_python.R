#' Use Python
#'
#' Associate a version of Python with your lesson. This is essentially a wrapper
#' around [renv::use_python()]. To add Python packages, use [py_install()].
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

  ## Load the renv profile, unloading it upon exit
  on.exit({
    invisible(utils::capture.output(renv::deactivate(project = path), type = "message"))
  }, add = TRUE)
  renv::load(project = path)

  renv::use_python(python = python, type = type, ...)
}


#' Install Python packages and add them to the cache
#'
#' Installs Python packages with [reticulate::py_install()] and then records
#' them in the renv environment. This ensures [manage_deps()] keeps track of the
#' Python packages as well.
#'
#' @param packages Python packages to be installed as a character vecto.
#' @param path path to your lesson. Defaults to the current working directory.
#' @param ... Further arguments to be passed to [reticulate::py_install()]
#'
#' @details
#' Unlike with R packages, \pkg{renv} is not yet capable of automatically
#' detecting Python dependencies. Therefore, this helper function is provided to
#' correctly install Python packages and recording them in the renv environment.
#' Subsequent calls of [manage_deps()] will then correctly restore the required
#' Python packages if needed.
#'
#' @export
py_install <- function(packages, path = ".",  ...) {

  ## Load the renv profile, unloading it upon exit
  renv::load(project = path)
  on.exit({
    invisible(utils::capture.output(renv::deactivate(project = path), type = "message"))
  }, add = TRUE)

  has_reticulate <- rlang::is_installed("reticulate")
  if (!has_reticulate) {
    cli::cli_alert("Adding `reticulate` as a dependency for Python package installation")
    renv::install("reticulate")
  }
  reticulate::py_install(packages = packages, ...)

  cli::cli_alert("Updating the package cache")
  renv::snapshot(lockfile = renv::paths$lockfile(project = path), prompt = FALSE)
}
