#' Lesson Runtime Dependency Management
#'
#' @description A customized provisioner for Carpentries Lessons based on
#'   \pkg{renv} that will install and maintain the requirements for the lesson
#'   while _respecting user environments_. This setup leads to several
#'   advantages:
#'
#'   - **reliable setup**: the version of the lesson built on the carpentries
#'     website will be the same as what you build on your computer because the
#'     packages will be identical
#'   - **environmentally friendly**: The lesson dependencies are NOT stored in
#'     your default R library and they will not alter your R environment.
#'   - **transparent**: any additions or deletions to the cache will be recorded
#'     in the lockfile, which is tracked by git.
#'
#'   The functions that control this cache are the following:
#'
#'   3. `manage_deps()`: Creates and updates the dependencies in your lesson.
#'      If no lockfile exists in your lesson, this will create one for you.
#'   4. `update_cache()`: fetches updates for the dependencies and applies them
#'      to your cache and lockfile.
#'
#' @param path path to the current project
#' @param profile the name of the new profile (default "lesson-requirements")
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
#'   Our flavor of `{renv}` applies a package cache explicitly to the content of
#'   the lesson, but does not impose itself as the default `{renv}` environment.
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
#' @rdname dependency_management
#' @seealso [use_package_cache()] and [no_package_cache()] for turning on and
#'   off the package cache, respectively.
#' @return if `snapshot = TRUE`, a nested list representing the lockfile will be
#'   returned.
manage_deps <- function(path = ".", profile = "lesson-requirements", snapshot = TRUE, quiet = FALSE) {

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
  res <- callr::r(
    func = callr_manage_deps,
    args = args,
    show = !quiet,
    spinner = sho,
    user_profile = FALSE,
    env = c(callr::rcmd_safe_env(),
      "RENV_PROFILE" = profile,
      "R_PROFILE_USER" = fs::path(tempfile(), "nada"),
      "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache_available())
  )
  invisible(res)
}

#' Fetch updates for Package Cache
#'
#' @param prompt if `TRUE`, a message will show you the packages that will be
#'   updated in your lockfile and ask for your permission. This is the default
#'   if it's running in an interactive session.
#' @rdname dependency_management
#' @export
update_cache <- function(path = ".", profile = "lesson-requirements", prompt = interactive(), quiet = !prompt, snapshot = TRUE) {
  path <- root_path(path)
  prof <- Sys.getenv("RENV_PROFILE")
  on.exit({
    invisible(utils::capture.output(renv::deactivate(path), type = "message"))
    Sys.setenv("RENV_PROFILE" = prof)
  }, add = TRUE)
  Sys.setenv("RENV_PROFILE" = profile)
  renv::load(project = path)
  lib <- renv::paths$library(project = path)
  if (prompt) {
    updates <- renv::update(library = lib, check = TRUE, prompt = TRUE)
    if (isTRUE(updates)) {
      return(invisible())
    }
    if (packageVersion("renv") < "0.17.1") {
      wanna_update <- "Do you want to update the following packages?"
      cli::cli_alert(wanna_update)
      ud <- utils::capture.output(print(updates))
      message(paste(ud, collapse = "\n"))
    } else {
      wanna_update <- "Do you want to update these packages?"
      cli::cli_alert(wanna_update)
    }
    res <- utils::menu(c("Yes", "No"))
    if (res != 1) {
      no <- "Not updating at this time"
      cli::cli_alert_info(no)
      return(invisible())
    }
  }
  updates <- renv::update(library = lib, prompt = FALSE)
  if (snapshot) {
    renv::snapshot(lockfile = renv::paths$lockfile(project = path), prompt = FALSE)
  }
  updates
}

#' Pin a resource to a specific version
#'
#' This is a wrapper around [renv::record()], which helps you record a package
#' or set of packages in your lockfile. It can be useful when you want to
#' upgrade or downgrade a specific package.
#'
#' @param records a character vector or list of packages/resources to include
#' in the lockfile. The most common way to do this is to use the
#' `[package]@[version]` syntax (e.g. `gert@0.1.3`), but there are other
#' specifications where you can specify the remote repository. See
#' [renv::record()] for details.
#' @param profile default to the profile for the lesson. Defaults to
#' `lesson-requirements`. Only use this if you know what you are doing.
#' @param path path to your lesson. Defaults to the current working directory.
#'
#' @return the contents of the lockfile, invisibly
#' @export
#' @rdname dependency_management
pin_version <- function(records = NULL, profile = "lesson-requirements", path = ".") {
  prof <- Sys.getenv("RENV_PROFILE")
  wd   <- getwd()
  on.exit({
    invisible(utils::capture.output(renv::deactivate(path), type = "message"))
    Sys.setenv("RENV_PROFILE" = prof)
    setwd(wd)
  })
  path <- root_path(path)
  setwd(path)
  Sys.setenv("RENV_PROFILE" = profile)
  lockfile <- renv::paths$lockfile(project = path)
  renv::record(records, lockfile = lockfile, project = path)
}
