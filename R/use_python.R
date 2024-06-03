#' Add Python as a lesson dependency
#'
#' Associate a version of Python with your lesson. This is essentially a wrapper
#' around [renv::use_python()].
#'
#' @param path path to the current project
#' @inheritParams renv::use_python
#' @param open if interactive, the lesson will open in a new editor window.
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
#' @examples
#' \dontrun{
#' tmp <- tempfile()
#' on.exit(unlink(tmp))
#'
#' ## Create lesson with Python support
#' lsn <- create_lesson(tmp, name = "This Lesson", open = FALSE, add_python = TRUE)
#' lsn
#'
#' ## Add Python as a dependency to an existing lesson
#' setwd(lsn)
#' use_python()
#'
#' ## Install Python packages and record them as dependencies
#' py_install("numpy")
#' }
use_python <- function(path = ".", python = NULL,
                       type = c("auto", "virtualenv", "conda", "system"),
                       open = rlang::is_interactive(), ..., quiet = FALSE) {

  ## Make sure reticulate is installed
  install_reticulate(path = path, quiet = quiet)

  ## Generate function to run in separate R process
  use_python_with_renv <- function(path, python, type, ...) {
    prof <- Sys.getenv("RENV_PROFILE")
    renv::use_python(project = path, python = python, type = type, ...)

    ## NOTE: use_python() deactivates the default profile,
    ## see https://github.com/rstudio/renv/issues/1217
    ## Workaround: re-activate the profile
    renv::activate(project = path, profile = prof)
  }
  callr_use_python <- with_renv_factory(use_python_with_renv,
    renv_path = path, renv_profile = "lesson-requirements"
  )

  ## Run in separate R process
  callr::r(
    func = function(f, path, python, type,  ...) f(path = path, python = python , type = type, ...),
    args = list(f = callr_use_python, path = path, python = python, type = type, ...),
    show = !quiet
  )

  if (open) {
    if (usethis::proj_activate(path)) {
      on.exit()
    }
  }
  invisible(path)
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

  ## Ensure reticulate is installed
  install_reticulate(path = path)

  py_install_with_renv <- function(packages, ...) {
    reticulate::py_install(packages = packages, ...)
    cli::cli_alert("Updating the package cache")
    renv::snapshot(prompt = FALSE)
  }
  callr_py_install <- with_renv_factory(py_install_with_renv,
    renv_path = path, renv_profile = "lesson-requirements"
  )

  ## Run in separate R process
  callr::r(
    func = function(f, packages) f(packages = packages),
    args = list(f = callr_py_install, packages = packages),
    show = TRUE
  )

  invisible(TRUE)
}


## Helper to install reticulate in the lesson's renv environment and record it as a dependency
install_reticulate <- function(path, quiet = FALSE) {

  if (!check_reticulate_installable()) {
    cli::cli_alert("`reticulate` can not be installed on this system. Skipping installation.")
    return(invisible(FALSE))
  }

  ## Record reticulate as a dependency for renv
  dep_file <- fs::path(path, "dependencies.R")
  write("library(reticulate)", file = dep_file, append = TRUE)

  ## Install reticulate through manage_deps()
  manage_deps(path = path, quiet = quiet)

  invisible(TRUE)
}

check_reticulate_installable <- function() {
  minimal_major <- 4
  r_compatible <- is_r_version_greater_than(minimal_major = minimal_major)
  if (!r_compatible) {
    cli::cli_warn("R version {minimal_major}.0 or higher is required for reticulate")
  }
  r_compatible
}

is_r_version_greater_than <- function(minimal_major = 4) {
  R.version$major >= minimal_major
}
