#' Lesson Runtime Dependency Management
#'
#' @description A customized provisioner for Carpentries Lessons based on
#'   \pkg{renv} that will _respect user environments_. This setup leads to
#'   several advantages:
#'
#'   - **reliable setup**: the version of the lesson built on the carpentries
#'     website will be the same as what you build on your computer because the
#'     packages will be identical
#'   - **environmentally friendly**: The lesson dependencies are NOT stored in
#'     your default R library and they will not alter your R environment.
#'   - **transparent**: any additions or deletions to the cache will be recorded
#'     in the lockfile, which is tracked by git.
#'
#' @param path path to the current project
#' @param profile the name of the new profile (default "packages")
#' @param snapshot if `TRUE`, packages from the cache are added to the lockfile
#'   (default). Setting this to `FALSE` will add packages to the cache and not
#'   snapshot them.
#' @param quiet if `TRUE`, output will be suppressed, defaults to `FALSE`,
#'   providing output about different steps in the process of updating the local
#'   dependencies.
#'
#' @details The \pkg{renv} package provides a very useful interface to bring one
#'   aspect of reproducibility to R projects. Because people working on
#'   Carpentries lessons are also working academics and will likely have
#'   projects on their computer where the package versions are necessary for
#'   their work, it's important that those environments are respected.
#'  
#'   Our flavor of {renv} applies a package cache explicitly to the content of
#'   the lesson, but does not impose itself as the default {renv} environment.
#'
#'   This provisioner will do the following steps:
#'
#'   0. check for consent to use the package cache via [use_package_cache()]
#'      and prompt for it if needed
#'   1. check if the profile has been created and create it if needed via
#'      [renv::init()]
#'   2. populate the cache with packages needed from the user's system and
#'      download any that are missing via [renv::hydrate()]. This includes all
#'      new packages that have been added to the lesson.
#'   3. If there is a lockfile already present, make sure the packages in the
#'      cache are aligned with the lockfile (downloading sources if needed) via
#'      [renv::restore()].
#'   4. Record the state of the cache in a lockfile tracked by git. This will
#'      include adding new packages and removing old packages. [renv::snapshot()]
#'
#'   When the lockfile changes, you will see it in git and have the power to
#'   either commit or restore those changes.
#'
#' @export
#' @rdname package_cache
#' @return if `snapshot = TRUE`, a nested list representing the lockfile will be
#'   returned.
manage_deps <- function(path = ".", profile = "packages", snapshot = TRUE, quiet = FALSE) {

  use_package_cache(quiet = quiet)
  # Enforce absolute path here
  path <- fs::path_abs(root_path(path))

  if (!fs::dir_exists(fs::path(path, "renv/profiles", profile))) {
    renv_setup_profile(path, profile)
    lockfile_exists <- FALSE
  } else {
    lockfile_exists <- TRUE
  }

  args <- list(
    path = path,
    repos = renv_carpentries_repos(),
    snapshot = snapshot,
    lockfile_exists = lockfile_exists
  )

  sho <- !(quiet || identical(Sys.getenv("TESTTHAT"), "true"))
  callr::r(function(path, profile, repos, snapshot, lockfile_exists) {
    wd        <- getwd()
    old_repos <- getOption("repos")

    # Reset everything on exit
    on.exit({
      setwd(wd)
      options(repos = old_repos)
    }, add = TRUE)

    # Set up our working directory and the default repositories
    setwd(path)
    options(repos = repos)
    # Steps to update a {renv} environment regardless of whether or not the user
    # has initiated {renv} in the first place
    #
    # 1. find the packages we need from the global library or elsewhere, and 
    #    load them into the profile's library
    cli::cli_alert("Searching for and installing available dependencies")
    hydra <- renv::hydrate(library = renv::paths$library(), update = FALSE)
    # 2. If the lockfile exists, we update the library to the versions that are
    #    recorded.
    if (lockfile_exists) {
      cli::cli_alert("Restoring any dependency versions")
      res <- renv::restore(library = renv::paths$library(), 
        lockfile = renv::paths$lockfile(),
        prompt = FALSE)
    }
    if (snapshot) {
      # 3. Load the current profile, unloading it when we exit
      renv::load()
      on.exit(renv::deactivate(), add = TRUE)
      # 4. Snapshot the current state of the library to the lockfile to 
      #    synchronize
      cli::cli_alert("Recording changes in lockfile")
      snap <- renv::snapshot(project = path,
        lockfile = renv::paths$lockfile(),
        prompt = FALSE
      )
    }
  },
  args = args,
  show = !quiet,
  spinner = sho,
  user_profile = FALSE,
  env = c(callr::rcmd_safe_env(),
    "RENV_PROFILE" = profile,
    "R_PROFILE_USER" = fs::path(tempfile(), "nada"),
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()))
}

#' Fetch updates for Package Cache
#'
#' @param prompt if `TRUE`, a message will show you the packages that will be
#'   updated in your lockfile and ask for your permission. This is the default
#'   if it's running in an interactive session.
#' @rdname package_cache
#' @export
fetch_updates <- function(path = ".", profile = "packages", prompt = interactive(), quiet = !prompt, snapshot = TRUE) {
  prof <- Sys.getenv("RENV_PROFILE")
  on.exit({
  x <- capture.output(renv::deactivate(project = path), type = "message")
  Sys.setenv("RENV_PROFILE" = prof)
  })
  Sys.setenv("RENV_PROFILE" = "packages")
  renv::load(project = path)
  if (prompt) {
    updates <- renv::update(check = TRUE, prompt = TRUE)
    if (isTRUE(updates)) {
      return(invisible())
    }
    cli::cli_alert("Do you want to update the following packages?")
    ud <- utils::capture.output(print(updates))
    message(paste(ud, collapse = "\n"))
    res <- utils::menu(c("Yes", "No"))
    if (res != 1) {
      cli::cli_alert_info("Not updating at this time")
      return(invisible())
    }
  }
  updates <- renv::update(project = path, prompt = FALSE)
  if (snapshot) {
    renv::snapshot(lockfile = renv::paths$lockfile(), prompt = FALSE)
  }
  updates
}

#' Give Consent to Use Package Cache
#'
#' @description
#'
#' This function explicitly gives \pkg{sandpaper} permission to use \pkg{renv}
#' to create a package cache for this and future lessons. You can also use
#' the `sandpaper.use_renv` option to toggle between this and not using the 
#' cache.
#'
#' ## Background
#'
#' By default, \pkg{sandpaper} will happily build your lesson using the packages
#' available in your default R library, but this can be undesirable for a couple
#' of reasons:
#'
#' 1. You may have a different version of a lesson package that is used on the
#'    lesson website, which may result in strange errors, warnings, or incorrect
#'    output.
#' 2. You might be very cautious about updating any components of your current
#'    R infrastructure because your work depends on you having the correct 
#'    package versions installed.
#'
#' To alleviate these concerns, \pkg{sandpaper} uses the \pkg{renv} package to
#' generate a lesson-specific library that has package versions pinned until the
#' lesson authors choose to update them. This is designed to be
#' minimally-invasive, using the packages you already have and downloading from
#' external repositories only when necessary.
#'
#' ## What if I've used \pkg{renv} before?
#'
#' If you have used \pkg{renv} in the past, then there is no need to give
#' consent to use the cache.
#'
#' ## How do I turn off the feature temporarily?
#'
#' To turn off the feature you can use `options(sandpaper.use_renv = FALSE)`.
#' \pkg{sandpaper} will respect this option when building your lesson and will
#' use your global library instead.
#' 
#' @param prompt if `TRUE` (default when interactive), a prompt for consent 
#'   giving information about the proposed modifications will appear on the
#'   screen asking for the user to choose to apply the changes or not.
#' @param quiet if `TRUE`, messages will not be issued unless `prompt = TRUE`.
#'   This defaults to the opposite of `prompt`.
#'
#' @export
#' @return nothing. this is used for its side-effect
#' @examples
#' if (!getOption("sandpaper.use_renv") && interactive()) {
#'   # The first time you set up {renv}, you will need permission
#'   use_package_cache(prompt = TRUE)
#' }
#'
#' if (getOption("sandpaper.use_renv") && interactive()) {
#'   # If you have previously used {renv}, permission is implied
#'   use_package_cache(prompt = TRUE)
#'
#'   # You can temporarily turn this off
#'   options("sandpaper.use_renv" = FALSE)
#'   getOption("sandpaper.use_renv") # should be FALSE
#'   use_package_cache(prompt = TRUE)
#' }
use_package_cache <- function(prompt = interactive(), quiet = !prompt) {
  consent_ok <- "Consent to use package cache provided"
  if (getOption("sandpaper.use_renv") || !prompt) {
    options(sandpaper.use_renv = TRUE)
    msg <- renv_has_consent(force = TRUE)
    if (grepl("nothing to do", msg))  {
      info <- consent_ok
    } else {
      info <- "{consent_ok}\n{.emph {msg}}"
    }
    if (!quiet) {
      cli::cli_alert_info(info)
    }
    return(invisible())
  }
  msg <- renv_has_consent()
  if (getOption("sandpaper.use_renv")) {
    if (!quiet) {
      cli::cli_alert_info("Consent for {.pkg renv} provided---consent for package cache implied.")
    }
    return(invisible())
  }
  options <- package_cache_msg(msg)
  x <- utils::menu(options)
  if (x == 1) {
    options(sandpaper.use_renv = TRUE)
    msg <- renv_has_consent(force = TRUE)
    if (!quiet) {
      cli::cli_alert_info("{consent_ok}\n{.emph {msg}}")
    }
  } else {
    options(sandpaper.use_renv = FALSE)
    options(renv.consent = FALSE)
  }
  cli::cli_end()
  return(invisible())
}

package_cache_msg <- function(msg) {
  our_lines <- grep("^(renv maintains|This path can be customized)", msg)
  RENV_MESSAGE <- msg[our_lines[1]:our_lines[2]]
  RENV_MESSAGE <- paste(RENV_MESSAGE, collapse = "\n")
  txt <- readLines(system.file("templates", "consent-form.txt", package = "sandpaper"))
  txt <- paste(txt, collapse = "\n")
  cli::cli_div(theme = sandpaper_cli_theme())
  cli::cli_h1("Caching Build Packages for Generated Content")
  cli::cli_text(txt)
  cli::cli_rule("Enter your selection or press 0 to exit")
  options <- c(
    glue::glue("{cli::style_bold('Yes')}, please use the package cache (recommended)"),
    glue::glue("{cli::style_bold('No')}, I want to use my default library")
  )
}
