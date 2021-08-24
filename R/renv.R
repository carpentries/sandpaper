# At the moment, {sandpaper} has no method to manage dependencies in a lesson, 
# you just have to have them installed on your machine. 
#
# I _could_ simply drop in the dependency management that we have for the styles
# repository, but I want to avoid the situation where I accidentally clobber a
# maintainer's R installation. 
#
# These are my notes that I have about renv and what it does. 
#
# The global cache
# ----------------
#
# The global cache is a really cool concept and it's well executed. It's a cache
# of packages used across renv projects. 
# When you do an interactive snapshot in {renv} the first time, it will give
# you the output from `renv::consent()`, however, if it's non-interactive, then
# you will not get the prompt and it will create the default 
#
# All you need is lock
# --------------------
#
# First: you don't _need_ anything more than a lockfile for _renv_:
#   <https://twitter.com/JosiahParry/status/1352294664607576068>
#
# You can do your work and `renv::snapshot()` when you are done and it creates
# a renv.lock for you: yay!
#
# The drawback here is that you cannot snapshot a package that does not
# currently exist on your computer (I tried addng a demonstration of the cowsay
# package, but it refused to enter the lockfile).
#
# The solution here is to run renv::record() with the discovered dependencies
# for the lockfile. 
#
# Activate Profiles
# -----------------
#
# So, as of renv 0.13, we have been able to take advantage of project-specific
# profiles. These are self-contained libraries and lockfiles that should be 
# unobtrusive. The structure looks like 
# renv
# ├── activate.R
# ├── local
# │   └── profile
# ├── profiles
# │   ├── sandpaper
# │   │   ├── renv
# │   │   │   └── library
# │   │   └── renv.lock
# │   └── packages
# │       ├── renv
# │       │   └── library
# │       └── renv.lock
# └── staging
#
# To create this, we use the following steps:
#
# op <- options()
# on.exit(options(op), add = TRUE)
# options(repos = c(
#   carpentries = "https://carpentries.r-universe.dev/",
#   carpentries_archive = "https://carpentries.github.io/drat",
#   CRAN = "https://cloud.r-project.org"
# ))
# on.exit({
#   out <- capture.output(renv::deactivate(), type = "message")
# }, add = TRUE)
# renv::activate(profile = "sandpaper")
# renv::snapshot(packages = c("sandpaper", "pegboard", "varnish"))
# out <- capture.output(renv::deactivate(), type = "message")
#
# renv::activate(profile = "packages")
# renv::snapshot()
# renv::restore()
# pak <- renv::dependencies()$Package
# renv::install(setdiff(pak, rownames(installed.packages)))
# renv::snapshot()
#
#
#
# Use it
# ------
#
# I don't know when it became part of renv, but there is a function called 
# `renv::use()`, which takes in a vector of packages _or_ a lockfile and will
# determine if they need to be installed, install them to the cache and then 
# set a temporary library for that session. 
#
#  - doesn't isntall into the user's default library
#  - uses a temporary library with the cache
#
# The only drawback right now is the fact that if we use a lockfile for the 
# source, we run into the same problem that we had when we used a lockfile with
# restore

#' 
carpentries_repos <- function() {
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
    # options(renv.config.cache.symlinks = FALSE)
    wd <- getwd()
    on.exit(setwd(wd))
    setwd(path)
    renv::init(bare = TRUE, restart = FALSE, profile = profile)
    renv::deactivate()
  }, 
  args = list(path = path, profile = profile),
  show = FALSE,
  env = c(callr::rcmd_safe_env(), "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()))
}

renv_cache <- function() {
  if (res <- is.null(getOption("sandpaper.test_fixture"))) {
    res <- Sys.getenv("RENV_CONFIG_CACHE_SYMLINKS")
  }
  res
}

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
manage_deps <- function(path = ".", profile = "packages", snapshot = TRUE, quiet = TRUE) {

  if (!fs::dir_exists(fs::path(path, "renv/profiles", profile))) {
    renv_setup_profile(path, profile)
    lockfile_exists <- FALSE
  } else {
    lockfile_exists <- TRUE
  }

  args <- list(
    path = path,
    profile = profile,
    repos = carpentries_repos(),
    snapshot = snapshot,
    lockfile_exists = lockfile_exists
  )

  sho <- !(quiet || identical(Sys.getenv("TESTTHAT"), "true"))
  callr::r(function(path, profile, repos, snapshot, lockfile_exists) {
    # options(renv.config.cache.symlinks = FALSE)
    wd        <- getwd()
    old_repos <- getOption("repos")
    prof      <- Sys.getenv("RENV_PROFILE")

    # Reset everything on exit
    on.exit({
      Sys.setenv(RENV_PROFILE = prof)
      setwd(wd)
      options(repos = old_repos)
    }, add = TRUE)

    # Set up our working directory and, importantly, our {renv} profile
    setwd(path)
    options(repos = repos)
    Sys.setenv(RENV_PROFILE = profile)
    # Steps to update a {renv} environment regardless of whether or not the user
    # has initiated {renv} in the first place
    #
    # 1. find the packages we need from the global library or elsewhere, and 
    #    load them into the profile's library
    capture.output(hydra <- renv::hydrate(library = renv::paths$library(), update = FALSE))
    # 2. If the lockfile exists, we update the library to the versions that are
    #    recorded.
    if (lockfile_exists) {
      capture.output(res <- renv::restore(library = renv::paths$library(), 
        lockfile = renv::paths$lockfile(),
        prompt = FALSE))
    }
    if (snapshot) {
      # 2. Load the current profile, unloading it when we exit
      renv::load()
      on.exit(renv::deactivate(), add = TRUE)
      # 3. Snapshot the current state of the library to the lockfile to 
      #    synchronize
      capture.output(snap <- renv::snapshot(project = path,
        lockfile = renv::paths$lockfile(),
        prompt = FALSE
      ))
    }
  }, 
  args = args, 
  show = sho, 
  env = c(callr::rcmd_safe_env(), "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()))
}

#nocov start
# very internal function for me to burn everything down. This will remove
# the local library, local cache, and the entire {renv} cache. 
renv_burn_it_down <- function(path = ".", profile = "packages") {
  callr::r(function(path, profile) {
    wd        <- getwd()
    prof      <- Sys.getenv("RENV_PROFILE")

    # Reset everything on exit
    on.exit({
      Sys.setenv(RENV_PROFILE = prof)
      setwd(wd)
    }, add = TRUE)
    unlink(renv::paths$library(), recursive = TRUE, force = TRUE)
    unlink(renv::paths$cache(), recursive = TRUE, force = TRUE)
    unlink(renv::paths$root(), recursive = TRUE, force = TRUE)
  }, args = list(path = path, profile = profile))
}
#nocov end
