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
  site_path    <- make_here(path_built(path))

  episodes  <- get_schedule(path)
  episodes  <- episode_path(episodes)
  artifacts <- get_artifact_files(path)
  built     <- get_built_files(path)
  any_built <- if (rebuild || length(built) == 0) FALSE else TRUE

  names(episodes)   <- get_episode_slug(episodes)
  new_hashes        <- tools::md5sum(episodes)
  names(new_hashes) <- names(episodes)

  if (any_built) {
    old_hashes        <- vapply(built, get_hash, character(1))
    names(old_hashes) <- get_episode_slug(built)
  } else {
    old_hashes <- character(0)
  }

  to_be_built <- data.frame(
    episode = episodes, 
    hash = new_hashes, 
    stringsAsFactors = FALSE
  )

  if (any_built) {
    # Find all episods that have the same name
    same_name <- intersect(names(old_hashes), names(new_hashes))

    # Only build the episodes that have changed. 
    to_be_built   <- to_be_built[new_hashes %nin% old_hashes[same_name], , drop = FALSE]
    to_be_removed <- setdiff(names(old_hashes), names(new_hashes))
  } else {
    to_be_removed <- character(0)
  }

  # Copy the files to the assets directory -------------------------------------
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
  for (i in seq_len(nrow(to_be_built))) {
    build_episode_md(
      path    = to_be_built$episode[i],
      hash    = to_be_built$hash[i],
      workdir = site_path("assets"),
      quiet   = quiet
    )
  }

  # Remove detritus ------------------------------------------------------------
  if (length(to_be_removed)) fs::file_delete(stats::na.omit(built[to_be_removed]))

  # Update metadata and navbar -------------------------------------------------
  if (nrow(to_be_built) > 0) {
    update_site_timestamp(path)
  }
  update_site_menu(path, episodes)
  invisible(to_be_built)
}





