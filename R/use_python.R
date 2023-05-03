#' Add Python as a lesson dependency
#'
#' Associate a version of Python with your lesson. This is essentially a wrapper
#' around [renv::use_python()].
#'
#' @param path path to the current project
#' @inheritParams renv::use_python
#' @param ... Further arguments to be passed on to [renv::use_python()]
#'
#' @details
#' This helper function adds Python as a dependency to the \pkg{renv} lockfile
#' and installs a Python environment of the specified `type`. This ensures any
#' Python packages used for this lesson are installed separately from the user's
#' main library, much like the R packages (see [manage_deps()]).
#'
#' Note that \pkg{renv} is not (yet) able to automatically detect Python package
#' dependencies (e.g. from `import` statements). So any required Python packages
#' still need to be installed manually. To facilitate this, the [py_install()]
#' helper is provided. This will install Python packages in the correct
#' environment and record them in a `requirements.txt` file, which will be
#' tracked by \pkg{renv}. Subsequent calls of [manage_deps()] will then
#' correctly restore the required Python packages if needed.
#'
#' @export
#' @rdname use_python
#' @seealso [renv::use_python()], [py_install()]
#' @return The path to the Python executable. Note that this function is mainly
#'   called for its side effects.
use_python <- function(path = ".", python = NULL,
                       type = c("auto", "virtualenv", "conda", "system"), ...) {

  wd <- getwd()

  ## Load the renv profile, unloading it upon exit
  on.exit({
    invisible(utils::capture.output(renv::deactivate(project = path), type = "message"))
    setwd(wd)
  }, add = TRUE)

  ## Set up working directory, avoids some renv side effects
  setwd(path)
  renv::load(project = path)
  prof <- Sys.getenv("RENV_PROFILE")

  renv::use_python(python = python, type = type, ...)

  ## NOTE: use_python() deactivates the default profile, see https://github.com/rstudio/renv/issues/1217
  ## Workaround: re-activate the profile
  renv::activate(project = path, profile = prof)
}


#' Install Python packages and add them to the cache
#'
#' To add Python packages, `py_install()` is provided, which installs Python
#' packages with [reticulate::py_install()] and then records them in the renv
#' environment. This ensures [manage_deps()] keeps track of the Python packages
#' as well.
#'
#' @param packages Python packages to be installed as a character vecto.
#' @param path path to your lesson. Defaults to the current working directory.
#' @param ... Further arguments to be passed to [reticulate::py_install()]
#'
#' @export
#' @rdname use_python
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
