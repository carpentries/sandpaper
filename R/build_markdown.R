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
#' @seealso [build_episode_md()]
build_markdown <- function(path = ".", rebuild = FALSE, quiet = FALSE) {

  episode_path <- path_episodes(path)
  outdir       <- path_built()

  # Determine build status for the episodes ------------------------------------
  source_list <- list(
    conduct = fs::path(root_path(path), "CODE_OF_CONDUCT.md"),
    episodes = get_episodes(path, trim = FALSE), # use get_episodes here for order
    learners = get_learners(path, trim = FALSE), # use get_learners here for order
    instructors = get_instructors(path, trim = FALSE), # use get_instructors here for order
    profiles = get_profiles(path, trim = FALSE), # use get_profiles here for order
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
    FUN = function(i) enforce_dir(fs::path(episode_path, i)),
    FUN.VALUE = character(1)
  )
  to_copy <- c(to_copy, artifacts)
  for (f in to_copy) {
    copy_assets(f, outdir)
  }

  # Render the episode files to the built directory ----------------------------
  for (i in seq_len(nrow(build_status$build))) {
    build_episode_md(
      path    = build_status$build$source[i],
      hash    = build_status$build$hash[i],
      outdir  = outdir,
      workdir = outdir,
      quiet   = quiet
    )
  }

  # Remove detritus ------------------------------------------------------------
  remove <- build_status$remove
  if (length(remove)) fs::file_delete(stats::na.omit(built[remove]))

  # Update metadata ------------------------------------------------------------
  if (nrow(build_status$build) > 0) {
    update_site_timestamp(path)
  }
  # Update the navbar ----------------------------------------------------------
  update_site_menu(path,
    episodes    = source_list$episodes,
    learners    = source_list$learners,
    instructors = source_list$instructors,
    profiles    = source_list$profiles
  )
  invisible(build_status$build)
}





