## These helpers are used in `test-use_python.R`, they are implemented separately to ensure the
## temporary loading of the renv environment doesn't interfere with the testing environment

## Allows running relevant checks with the test lesson's renv profile
with_renv_profile <- function(path, code, profile = "lesson-requirements", ...) {
  path <- normalizePath(path)
  code <- rlang::enexpr(code)
  callr::r(
    func = function(path, code) {
      setwd(path)
      renv::load(path)
      eval(code)
    },
    args = list(path = path, code = code),
    env = c(callr::rcmd_safe_env(), "RENV_PROFILE" = profile),
    ...
  )
}

get_renv_env <- function(lsn, which = "RETICULATE_PYTHON") {
  which <- rlang::enexpr(which)
  with_renv_profile(lsn, Sys.getenv(!!which))
}

check_reticulate <- function(lsn) {
  with_renv_profile(lsn, rlang::is_installed("reticulate"))
}

check_reticulate_config <- function(lsn) {
  with_renv_profile(lsn, reticulate::py_config())
}

local_load_py_pkg <- function(lsn, package) {
  package <- rlang::enexpr(package)
  with_renv_profile(lsn, reticulate::import(!!package))
}

