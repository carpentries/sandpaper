#' Build plain markdown from the RMarkdown episodes
#'
#' In the spirit of {hugodown}, This function will build plain markdown files
#' as a minimal R package in the `site/` folder of your {sandpaper} lesson
#' repository tagged with the hash of your file to ensure that only files that
#' have changed are rebuilt. 
#' 
#' @param path the path to your repository (defaults to your current working
#' directory)
#' @param rebuild if `TRUE`, everything will be built from scratch as if there
#' was no cache. Defaults to `FALSE`, which will only build markdown files that
#' haven't been built before. 
#' 
#' @return `TRUE` if it was successful, a character vector of issues if it was
#'   unsuccessful.
#' 
#' @keywords internal
build_markdown <- function(path = ".", rebuild = FALSE, quiet = FALSE) {

  episode_path    <- make_here(path_episodes(path))
  learner_path    <- make_here(path_learners(path))
  instructor_path <- make_here(path_instructors(path))
  profile_path    <- make_here(path_profiles(path))
  
  # IDEA: expansion to other generators will be able to switch this part and
  #       still be able to copy things correctly
  outdir     <- path_built()
  build_path <- make_here(outdir)

  # Determine build status for the episodes ------------------------------------
  source_list <- list(
    conduct = fs::path(root_path(path), "CODE_OF_CONDUCT.md"),
    episodes = episode_path(get_episodes(path)), # use get_episodes here for order
    learners = learner_path(get_learners(path)), # use get_learners here for order
    instructors = instructor_path(get_instructors(path)), # use get_instructors here for order
    profiles = profile_path(get_profiles(path)), # use get_profiles here for order
    license  = fs::path(root_path(path), "LICENSE.md"),
    NULL
  )
  sources <- unlist(source_list, use.names = FALSE)
  names(sources) <- get_slug(sources)
  built <- get_markdown_files()
  build_status <- get_build_status(sources, built, rebuild)

  # Copy the files to the assets directory -------------------------------------
  artifacts <- get_artifacts(path, "episodes")
  to_copy <- vapply(
    c("data", "files", "fig"), 
    FUN = function(i) enforce_dir(episode_path(i)),
    FUN.VALUE = character(1)
  )
  to_copy <- c(to_copy, artifacts)
  for (f in to_copy) {
    copy_assets(f, build_path("assets"))
  }

  # Render the episode files to the built directory ----------------------------
  for (i in seq_len(nrow(build_status$build))) {
    build_episode_md(
      path    = build_status$build$episode[i],
      hash    = build_status$build$hash[i],
      outdir  = outdir,
      workdir = build_path("assets"),
      quiet   = quiet
    )
  }

  # Remove detritus ------------------------------------------------------------
  remove <- build_status$remove
  if (length(remove)) fs::file_delete(stats::na.omit(built[remove]))

  # Update metadata and navbar -------------------------------------------------
  if (nrow(build_status$build) > 0) {
    update_site_timestamp(path)
  }
  update_site_menu(path,
    episodes    = source_list$episodes,
    learners    = source_list$learners,
    instructors = source_list$instructors,
    profiles    = source_list$profiles
  )
  invisible(build_status$build)
}





