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
#' @return if `snapshot = TRUE`, a nested list representing the lockfile will be
#'   returned.
manage_deps <- function(path = ".", profile = "packages", snapshot = TRUE, quiet = FALSE) {

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
    "R_PROFILE_USER" = "nada",
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()))
}


use_package_cache <- function(prompt = interactive()) {
  if (getOption("sandpaper.use_renv") || !prompt) {
    options(sandpaper.use_renv = TRUE)
    options(renv.consent = TRUE)
    return(invisible())
  }
  msg <- renv_has_consent()
  our_lines <- grep("^(renv maintains|This path can be customized)", msg)
  RENV_MESSAGE <- paste(msg[our_lines[1]:our_lines[2]], collapse = "\n")
  txt <- readLines(system.file("templates", "consent-form.txt", package = "sandpaper"))
  txt <- paste(txt, collapse = "\n")
  # txt <- glue::glue(txt, .open = "<<", .close = ">>")
  cli::cli_div(theme = sandpaper_cli_theme())
  cli::cli_h1("Caching Build Packages for Generated Content")
  cli::cli_par()
  cli::cli_text(txt)
  cli::cli_end()
  cli::cli_rule("Enter your selection or press 0 to exit")
  options <- c(
    glue::glue("{cli::style_bold('Yes')}, please use the package cache (recommended)"),
    glue::glue("{cli::style_bold('No')}, I want to use my default library")
  )
  x <- utils::menu(options)
  if (x == 1) {
    options(sandpaper.use_renv = TRUE)
    options(renv.consent = TRUE)
  } else {
    options(sandpaper.use_renv = FALSE)
    options(renv.consent = FALSE)
  }
  cli::cli_end()
  return(invisible())
}
