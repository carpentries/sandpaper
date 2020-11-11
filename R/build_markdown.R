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

  episode_path <- make_here(path_episodes(path))
  # IDEA: expansion to other generators will be able to switch this part and
  #       still be able to copy things correctly
  site_path <- make_here(path_built(path))

  # Determine build status for the episodes ------------------------------------
  episodes  <- get_schedule(path)
  episodes  <- episode_path(episodes)
  built     <- get_built_files(path)
  names(episodes) <- get_episode_slug(episodes)
  build_status    <- get_build_status(episodes, built, rebuild)

  # Copy the files to the assets directory -------------------------------------
  artifacts <- get_artifact_files(path)
  to_copy <- vapply(
    c("data", "files", "fig"), 
    FUN = function(i) enforce_dir(episode_path(i)),
    FUN.VALUE = character(1)
  )
  to_copy <- c(to_copy, artifacts)
  for (f in to_copy) {
    copy_assets(f, site_path("assets"))
  }

  # Render the episode files to the built directory ----------------------------
  for (i in seq_len(nrow(build_status$build))) {
    build_episode_md(
      path    = build_status$build$episode[i],
      hash    = build_status$build$hash[i],
      workdir = site_path("assets"),
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
  update_site_menu(path, episodes)
  invisible(build_status$build)
}





