## Helpers to temporarily load renv environment
local_load_py_pkg <- function(lsn, package) {
  local_renv_load(lsn)
  reticulate::import(package)
}

## These helpers are used in `test-use_python.R`, they are implemented separately to ensure the
## temporary loading of the renv environment doesn't interfere with the testing environment
check_reticulate <- function(lsn) {
  local_renv_load(lsn)
  lib <- renv::paths$library(project = lsn)
  withr::local_libpaths(lib)
  rlang::is_installed("reticulate")
}

check_reticulate_config <- function(lsn) {
  local_renv_load(lsn)
  reticulate::py_config()
}

get_renv_env <- function(lsn, which = "RETICULATE_PYTHON") {
  local_renv_load(lsn)
  Sys.getenv(which)
}

## Temporarily load a renv profile, unloading it upon exit
local_renv_load <- function(lsn, env = parent.frame()) {
  ## NOTE: renv:::unload() is currently not exported: https://github.com/rstudio/renv/issues/1285
  withr::defer(renv:::unload(project = lsn), envir = env)
  renv::load(lsn)
}
