callr_build_episode_md <- function(path, hash, workenv, outpath, workdir, root, quiet) {
  # Shortcut if the source is a markdown file
  # Taken directly from tools::file_ext
  file_ext <- function (x) {
    pos <- regexpr("\\.([[:alnum:]]+)$", x)
    ifelse(pos > -1L, substring(x, pos + 1L), "")
  }
  # Also taken directly from tools::file_path_sans_ext
  file_path_sans_ext <- function (x) {
    sub("([^.]+)\\.[[:alnum:]]+$", "\\1", x)
  }
  if (file_ext(path) == "md") {
    file.copy(path, outpath, overwrite = TRUE)
    return(NULL)
  }
  # Load required packages if it's an RMarkdown file and we know the root 
  # directory.
  if (root != "") {
    renv::load(root)
    on.exit(invisible(utils::capture.output(renv::deactivate(root))), add = TRUE)
  }
  # Set knitr options for output ---------------------------
  ochunk <- knitr::opts_chunk$get()
  oknit  <- knitr::opts_knit$get()
  on.exit(knitr::opts_chunk$restore(ochunk), add = TRUE)
  on.exit(knitr::opts_knit$restore(oknit), add = TRUE)

  slug <- file_path_sans_ext(basename(outpath))

  knitr::opts_chunk$set(
    comment       = "",
    fig.align     = "center",
    class.output  = "output",
    class.error   = "error",
    class.warning = "warning",
    class.message = "output",
    fig.path      = file.path("fig", paste0(slug, "-rendered-"))
  )

  # Ensure HTML options like caption are respected by code chunks
  knitr::opts_knit$set(
    rmarkdown.pandoc.to = "markdown"
  )

  # Set the working directory -----------------------------
  wd <- getwd()
  on.exit(setwd(wd), add = TRUE)
  setwd(workdir)

  # Generate markdown -------------------------------------
  knitr::knit(
    input    = path,
    output   = outpath,
    envir    = workenv,
    quiet    = quiet,
    encoding = "UTF-8"
  )
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
    on.exit(invisible(utils::capture.output(renv::deactivate())), add = TRUE)
    # 4. Snapshot the current state of the library to the lockfile to 
    #    synchronize
    cli::cli_alert("Recording changes in lockfile")
    snap <- renv::snapshot(project = path,
      lockfile = renv::paths$lockfile(),
      prompt = FALSE
    )
  }
}
