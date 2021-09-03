#nocov start
# very internal function for me to burn everything down. This will remove
# the local library, local cache, and the entire {renv} cache. 
renv_burn_it_down <- function(path = ".", profile = "lesson-requirements") {
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

renv_should_rebuild <- function(path, rebuild, db_path, profile = "lesson-requirements") {
  # If rebuild is already TRUE OR we don't have permission to use {renv}, then
  # we return early.
  return_early <- rebuild || !getOption("sandpaper.use_renv")
  if (return_early) return(rebuild)
  hash <- renv_lockfile_hash(path, db_path, profile)
  return(rebuild || !isTRUE(hash$old == hash$new))
}

#' Get the hash for the previous and current lockfile (as recorded in the lesson)
#'
#' @param path path to the lesson
#' @param db_path path to the database
#' @param profile name of the profile renv uses for the lesson requirements
#' @return a named list:
#'  - old: hash value recoreded in the database
#'  - new: hash value of the current file
#' @keywords internal
renv_lockfile_hash <- function(path, db_path, profile = "lesson-requirements") {
  wd <- getwd()
  on.exit(setwd(wd), add = TRUE)
  setwd(path)
  rp <- Sys.getenv("RENV_PROFILE")
  on.exit(Sys.setenv(RENV_PROFILE = rp), add = TRUE)
  Sys.setenv(RENV_PROFILE = profile)
  # old_hash can be length zero here if the file or hash doesn't exist
  old_hash <- get_hash(renv::paths$lockfile(), db = db_path)
  # md5sum can be NA here if the file doesn't exist
  new_hash <- tools::md5sum(renv::paths$lockfile())
  return(list(old = old_hash, new = new_hash))
}

#' Try to use {renv}
#'
#' We use this when sandpaper starts to see if the user has previously consented
#' to {renv}. The problem is that [renv::consent()] throws `TRUE` if the user
#' has consented and an error if it has not :(
#'
#' This function wraps `renv::consent()` in a callr function and transforms the
#' error into `FALSE`. It sets the `sandpaper.use_renv` variable to the value of
#' that check and then returns the full text of the output if `FALSE` (this is
#' the WELCOME message that's given when someone uses {renv} for the first time)
#' and the last line of output if `TRUE` (a message either that a directory has
#' been created or that consent has already been provided.)
#'
#' @param force if `TRUE`, consent is forced to be TRUE, creating the cache
#'   directory if it did not exist before. Defaults to `FALSE`, which gently 
#'   inquires for consent.
#' @return a character vector
#' @keywords internal
try_use_renv <- function(force = FALSE) {
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

renv_check_consent <- function(path, quiet, src_files = NULL) {
  has_consent <- getOption("sandpaper.use_renv")
  if (has_consent) {
    lib <- manage_deps(path, snapshot = TRUE, quiet = quiet)
    if (!quiet) {
      cli::cli_alert_info("Using package cache in {renv::paths$root()}")
    }
  } else {
    needs_renv <- is.null(src_files) || any(fs::path_ext(src_files) %in% c("Rmd", "rmd"))
    if (!quiet && needs_renv) {
      msg1 <- "Consent to use package cache not given. Using default library."
      msg2 <- "use {.fn use_package_cache} to enable the package cache"
      msg3 <- "for reproducible builds."
      cli::cli_alert_info(msg1)
      cli::cli_alert(cli::style_dim(paste(msg2, msg3)), class = "alert-suggestion")
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
renv_setup_profile <- function(path = ".", profile = "lesson-requirements") {
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

