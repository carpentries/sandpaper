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
renv_find_uninstalled <- function(path = ".") {
  pak <- renv::dependencies(path)$Package
  setdiff(pak, rownames(installed.packages))
}

renv_setup <- function(path = ".") {
  default_libraries <- .libPaths()
  op <- options()
  on.exit(options(op), add = TRUE)
  options(repos = c(
    carpentries         = "https://carpentries.r-universe.dev/",
    carpentries_archive = "https://carpentries.github.io/drat",
    CRAN                = "https://cloud.r-project.org"
  ))
  on.exit({
    out <- capture.output(renv::deactivate(project = path), type = "message")
  }, add = TRUE)

  deps <- renv_find_uninstalled(path)
  wd <- getwd()
  on.exit(setwd(wd), add = TRUE)
  setwd(path)

  # Activate the sandpaper project for captured development of current features
  # cli::cli_h1("SANDPAPER")
  # cli::cli_h2("activate")
  # renv::activate(project = path, profile = "sandpaper")
  # ours <- c("renv", "sandpaper", "pegboard", "varnish")
  # this_library <- c(renv::paths$library(), default_libraries)
  # cli::cli_h2("snapshot")
  # renv::snapshot(packages = ours, prompt = FALSE)
  # cli::cli_h2("record")
  # renv::record(ours)
  # cli::cli_h1("hydrate")
  # out <- capture.output(renv::deactivate(project = path), type = "message")
  # renv::hydrate(library = this_library[1])
  # cli::cli_h1("reactivate")
  # renv::activate(profile = "sandpaper")
  # cli::cli_h1("restore")
  # renv::restore(prompt = FALSE)
  # cli::cli_h2("snapshot")
  # renv::snapshot(packages = ours, prompt = FALSE)

  # Activate the packages project for the pacakges we need to develop this
  # particular project. 
  cli::cli_h1("PACKAGES")
  cli::cli_h2("activate")
  renv::activate(profile = "packages")
  this_library <- c(renv::paths$library(), default_libraries)
  cli::cli_h2("snapshot")
  renv::snapshot(prompt = FALSE, library = this_library)
  cli::cli_h2("record")
  renv::record(deps)
  cli::cli_h1("hydrate")
  out <- capture.output(renv::deactivate(project = path), type = "message")
  renv::hydrate(library = this_library[1])
  cli::cli_h1("reactivate")
  renv::activate(profile = "packages")
  cli::cli_h1("restore")
  renv::restore(prompt = FALSE)
  cli::cli_h2("snapshot")
  renv::snapshot(packages = deps, prompt = FALSE, library = this_library)

  cli::cli_alert_info(deps)
}
