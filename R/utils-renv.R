#nocov start
# very internal function for me to burn everything down. This will remove
# the local library, local cache, and the entire `{renv}` cache.
renv_burn_it_down <- function(path = ".", profile = "lesson-requirements") {
  callr::r(function(path, profile) {
    wd <- getwd()
    # Reset everything on exit
    on.exit(setwd(wd), add = TRUE)
    unlink(renv::paths$library(project = path), recursive = TRUE, force = TRUE)
    unlink(renv::paths$cache(), recursive = TRUE, force = TRUE)
    unlink(renv::paths$root(), recursive = TRUE, force = TRUE)
  },
  user_profile = FALSE,
  env = c(callr::rcmd_safe_env(), "RENV_PROFILE" = profile),
  args = list(path = path))
}
#nocov end

renv_is_allowed <- function() {
  tolower(.Platform$OS.type) != "windows"
}

renv_should_rebuild <- function(path = ".", rebuild, db_path = "site/built/md5sum.txt", profile = "lesson-requirements") {
  return_early <- rebuild            || # if rebuild is TRUE OR
    !getOption("sandpaper.use_renv") || # if we are not using `{renv}` OR
    !package_cache_trigger()            # if the lockfile does not trigger rebuilds

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
  old_hash <- get_hash(renv::paths$lockfile(project = path), db = db_path)
  # md5sum can be NA here if the file doesn't exist
  new_hash <- tools::md5sum(renv::paths$lockfile(project = path))
  return(list(old = old_hash, new = new_hash))
}

#' Try to use `{renv}`
#'
#' We use this when sandpaper starts to see if the user has previously consented
#' to `{renv}`. The problem is that [renv::consent()] throws `TRUE` if the user
#' has consented and an error if it has not :(
#'
#' This function wraps `renv::consent()` in a callr function and transforms the
#' error into `FALSE`. It sets the `sandpaper.use_renv` variable to the value of
#' that check and then returns the full text of the output if `FALSE` (this is
#' the WELCOME message that's given when someone uses `{renv}` for the first time)
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
    }, args = list(ok = force),
      stdout = tmp,
    env = c(callr::rcmd_safe_env(),
      "RENV_VERBOSE" = "TRUE"))
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
      cli::cli_alert(cli::style_italic(paste(msg2, msg3)), class = "alert-suggestion")
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
    # NOTE: I do not know why, but this takes forever to run when no internet is
    # available. Kevin may know why.
    renv::init(project = path, bare = TRUE, restart = FALSE, profile = profile)
    renv::deactivate(project = path)
  },
  args = list(path = path, profile = profile),
  show = TRUE,
  spinner = FALSE,
  user_profile = FALSE,
  env = c(callr::rcmd_safe_env(),
    "R_PROFILE_USER" = "nada",
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache_available()))
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
work_with_cache <- function(profile = "lesson-requirements") {
  stopifnot("This only works interactively" = interactive())
  prof <- Sys.getenv("RENV_PROFILE")
  prompt <- getOption("prompt")
  done <- function() {
    renv::deactivate()
    Sys.setenv("RENV_PROFILE" = prof)
    options(prompt = prompt)
  }
  done_alert <- glue::glue("{cli::symbol$info} call `done()` when you are finished with the session.")
  on.exit({
    message(done_alert)
  })
  prmpt <- glue::glue("{cli::style_inverse('[lesson]')}{prompt}")
  Sys.setenv("RENV_PROFILE" = profile)
  renv::load()
  options(prompt = prmpt)
  return(done)
}

#' Print a diagnostics report for the package cache
#'
#' @param path the path to the lesson to use for diagnostics
#' @param profile the profile to work with (defaults to "lesson-requirements"
#'
#' @export
#' @keywords internal
renv_diagnostics <- function(path = ".", profile = "lesson-requirements") {
  prof <- Sys.getenv("RENV_PROFILE")
  on.exit({
    Sys.setenv("RENV_PROFILE" = prof)
    invisible(utils::capture.output(renv::deactivate(), type = "message"))
  }, add = TRUE)
  Sys.setenv("RENV_PROFILE" = profile)
  renv::load(project = path)
  renv::diagnostics(project = path)
}
#nocov end


renv_cache_available <- function() {
  rccs <- renv::config$cache.symlinks()
  stf  <- getOption("sandpaper.test_fixture")
  if (is.null(rccs) && is.null(stf)) {
    return("")
  } else if (!is.null(stf)) {
    return(FALSE)
  } else {
    return(rccs)
  }
}

callr_manage_deps <- function(path, repos, snapshot, lockfile_exists) {
  wd        <- getwd()
  old_repos <- getOption("repos")
  user_prof <- getOption("renv.config.user.profile")

  # Reset everything on exit
  on.exit({
    setwd(wd)
    options(repos = old_repos)
    options(renv.config.user.profile = user_prof)
  }, add = TRUE)

  # Set up our working directory and the default repositories
  setwd(path)
  options(repos = repos)
  options(renv.config.user.profile = FALSE)
  renv_lib  <- renv::paths$library(project = path)
  renv_lock <- renv::paths$lockfile(project = path)
  # Steps to update a `{renv}` environment regardless of whether or not the user
  # has initiated `{renv}` in the first place
  #
  # 1. find the packages we need from the global library or elsewhere, and
  #    load them into the profile's library
  cli::cli_alert("Searching for and installing available dependencies")
  #nocov start
  if (lockfile_exists) {
    # if there _is_ a lockfile, we only want to hydrate new packages that do not
    # previously exist in the library, because otherwise, we end up trying to
    # install packages that we should be able to install with renv::restore().
    installed <- utils::installed.packages(lib.loc = renv_lib)[, "Package"]
    deps <- unique(renv::dependencies(path = path, root = path, dev = TRUE)$Package)
    pkgs <- setdiff(deps, installed)
    needs_hydration <- length(pkgs) > 0
  } else {
    # If there is not a lockfile, we need to run a fully hydration
    pkgs <- NULL
    needs_hydration <- TRUE
  }
  #nocov end
  if (needs_hydration) {
    #nocov start
    if (packageVersion("renv") == "0.17.2") {
      # 2023-03-24 ---- renv cannot find the right packages
      # <https://github.com/rstudio/renv/issues/1177#issuecomment-1483295938>
      #
      # The problem here is that renv sees that 'callr' and other packages are
      # installed in other libraries on the .libPaths(), and so skips
      # installing them into the project library that is being hydrated.
      #
      # If you need a temporary workaround, it should suffice to "clear" the
      # library paths before calling hydrate()
      .libPaths(character())
    }
    #nocov end
    hydra <- renv::hydrate(packages = pkgs, library = renv_lib, update = FALSE,
      sources = .libPaths(), project = path, prompt = FALSE)
    #nocov start
    # NOTE: I am not testing this now because this code requires yet another
    # step to install packages. I will rely on the integration tests to help
    # me out here.
    #
    # When we have missing packages, this will help to search for and install
    # missing bioconductor packages, if this is the actual problem.
    if (length(hydra$missing)) {
      pkgs <- vapply(hydra$missing, function(pkg) pkg$package, character(1))
      cli::cli_alert_warning("Attempting to install missing packages assuming bioc")
      renv::install(paste0("bioc::", pkgs), library = renv_lib, project = path)
    }
    #nocov end
  }
  # 2. If the lockfile exists, we update the library to the versions that are
  #    recorded.
  if (lockfile_exists) {
    cli::cli_alert("Restoring any dependency versions")
    res <- renv::restore(project = path, library = renv_lib,
      lockfile = renv_lock, prompt = FALSE)
  }
  if (snapshot) {
    # 3. Load the current profile, unloading it when we exit
    renv::load(project = path)
    snap <- NULL
    on.exit({
      invisible(utils::capture.output(renv::deactivate(project = path), type = "message"))
      return(snap)
    }, add = TRUE)
    # 4. Snapshot the current state of the library to the lockfile to
    #    synchronize
    cli::cli_alert("Recording changes in lockfile")
    snap <- renv::snapshot(project = path, lockfile = renv_lock, prompt = FALSE)
  }
  return(NULL)
}
