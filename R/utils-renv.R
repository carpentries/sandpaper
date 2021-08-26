#nocov start
# very internal function for me to burn everything down. This will remove
# the local library, local cache, and the entire {renv} cache. 
renv_burn_it_down <- function(path = ".", profile = "packages") {
  callr::r(function(path, profile) {
    wd <- getwd()
    # Reset everything on exit
    on.exit(setwd(wd), add = TRUE)
    unlink(renv::paths$library(), recursive = TRUE, force = TRUE)
    unlink(renv::paths$cache(), recursive = TRUE, force = TRUE)
    unlink(renv::paths$root(), recursive = TRUE, force = TRUE)
  },
  user_profile = FALSE,
  env = c(callr::rcmd_safe_env(), "RENV_PROFILE" = profile),
  args = list(path = path))
}
#nocov end

# Get a boolean for whether or not the user has consented to using renv.
renv_has_consent <- function() {
  tryCatch(callr::r(function() renv::consent()), error = function(e) FALSE)
}

# Default repositories for our packages
renv_carpentries_repos <- function() {
  c(
    carpentries         = "https://carpentries.r-universe.dev/",
    carpentries_archive = "https://carpentries.github.io/drat",
    CRAN                = "https://cran.rstudio.com"
  )
}
#' Set up a renv profile
#'
#' @param path path to an empty project
#' @param profile the name of the new renv profile
#' @return this is normally called for it's side-effect
#' @noRd
renv_setup_profile <- function(path = ".", profile = "packages") {
  callr::r(function(path, profile) {
    wd <- getwd()
    on.exit(setwd(wd))
    setwd(path)
    renv::init(bare = TRUE, restart = FALSE, profile = profile)
    renv::deactivate()
  },
  args = list(path = path, profile = profile),
  show = TRUE,
  spinner = FALSE,
  user_profile = FALSE,
  env = c(callr::rcmd_safe_env(),
    "R_PROFILE_USER" = "nada",
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()))
}

renv_cache <- function() {
  renv::config$cache.symlinks() && is.null(getOption("sandpaper.test_fixture"))
}

