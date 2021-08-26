.onLoad <- function(...) {
  options(sandpaper.use_renv = renv_has_consent())
}
