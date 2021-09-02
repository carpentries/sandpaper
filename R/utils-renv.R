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

renv_is_allowed <- function() {
  !identical(Sys.getenv("TESTTHAT"), "true") || .Platform$OS.type != "windows"
}

# Get a boolean for whether or not the user has consented to using renv.
renv_has_consent <- function(force = FALSE) {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  x <- tryCatch({
    callr::r(function(ok) {
      options("renv.consent" = ok)
      renv::consent(provided = ok)
    }, args = list(ok = force), stdout = tmp)
  }, error = function(e) FALSE)
  options(sandpaper.use_renv = x)
  lines <- readLines(tmp)
  if (force) {
    lines <- lines[length(lines)]
  } 
  invisible(lines)
}

renv_check_consent <- function(path, quiet) {
  has_consent <- getOption("sandpaper.use_renv")
  if (has_consent) {
    lib <- manage_deps(path, snapshot = TRUE, quiet = quiet)
    if (!quiet) {
      cli::cli_alert_info("Using package cache in {renv::paths$root()}")
    }
  } else {
    if (!quiet) {
      msg1 <- "Consent to use package cache not given. Using default library."
      msg2 <- "use {.fn use_package_cache} to enable the package cache"
      msg3 <- "for reproducible builds."
      msg4 <- "You can switch between using your cache and the default library"
      msg5 <- "with {.code options(sandpaper.use_renv = TRUE)}"
      msg6 <- "({.code FALSE} for the default library)"
      cli::cli_alert_info(msg1)
      cli::cli_alert(cli::style_dim(paste(msg2, msg3)), class = "alert-suggestion")
      cli::cli_alert(cli::style_dim(paste(msg4, msg5, msg6)), class = "alert-suggestion")
    }
  }
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

#' (Experimental) Work with the package cache
#'
#' This function is designed so that you can work on your lesson inside the
#' package cache without overwriting your personal library.
#'
#' @return a function that will reset your R environment to its original state
#' @export
#' @keywords internal
#' @examples
#' if (interactive() && fs::dir_exists("episodes")) {
#'   library("sandpaper")
#'   done <- work_with_cache()
#'   print(.libPaths())
#'   # install.packages("cowsay") # install cowsay to your lesson cache
#'   # cowsay::say() # hello world
#'   # detach('package:cowsay') # detach the package from your current session
#'   done() # finish the session 
#'   # try(cowsay::say()) # this fails because it's not in your global library
#'   print(.libPaths())
#' }
#nocov start
work_with_cache <- function() {
  stopifnot("This only works interactively" = interactive())
  prof <- Sys.getenv("RENV_PROFILE")
  prompt <- getOption("prompt")
  done <- function() {
    renv::deactivate()
    Sys.setenv("RENV_PROFILE" = prof)
    options(prompt = prompt)
  }
  on.exit({
    cli::cli_alert_info("call {.fn done} when you are finished with the session")
  })
  renv::load()
  options(prompt = glue::glue("{cli::style_inverse('[lesson]')}{prompt}"))
  return(done)
}
#nocov end


renv_cache <- function() {
  renv::config$cache.symlinks() && is.null(getOption("sandpaper.test_fixture"))
}

