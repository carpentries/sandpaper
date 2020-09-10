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
    to_be_built   <- to_be_built[new_hashes %nin% old_hashes[same_name], ]
    to_be_removed <- setdiff(names(old_hashes), names(new_hashes))
  } else {
    to_be_removed <- character(0)
  }

  # Render the episode files to the built directory ----------------------------
  ochunk <- knitr::opts_chunk$get()
  on.exit(knitr::opts_chunk$restore(ochunk), add = TRUE)
  set_knitr_opts()

  for (i in seq_len(nrow(to_be_built))) {
    build_single_episode(to_be_built$episode[i], to_be_built$hash[i], quiet = quiet)
  }

  # Copy the files to the assets directory -------------------------------------
  to_copy <- vapply(
    c("data", "files", "extras", "fig"), 
    FUN = function(i) enforce_dir(episode_path(i)),
    FUN.VALUE = character(1)
  )
  to_copy <- c(to_copy, artifacts)
  for (f in to_copy) {
    copy_assets(f, site_path("assets"))
  }

  if (length(to_be_removed)) fs::file_delete(stats::na.omit(built[to_be_removed]))

  if (nrow(to_be_built) > 0) {
    update_site_timestamp(path)
  }
  update_site_menu(path, episodes)
  invisible(to_be_built)
}

build_single_episode <- function(path, hash, env = new.env(), quiet = FALSE) {
  # get output directory
  md      <- fs::path_ext_set(fs::path_file(path), "md")
  outpath <- fs::path(path_built(path), md)

  oknit <- knitr::opts_chunk$get()
  on.exit(knitr::opts_chunk$restore(oknit), add = TRUE)
  set_fig_path(fs::path_ext_remove(fs::path_file(md)))

  wd <- getwd()
  on.exit(setwd(wd), add = TRUE)
  setwd(path_episodes(path))

  # Generate markdown  
  res <- knitr::knit(
    text = readLines(path, encoding = "UTF-8"), 
    envir = env, 
    quiet = quiet,
    encoding = "UTF-8"
  )

  # append md5 hash to top of file
  output <- sub(
    "^---",
    paste("---\nsandpaper-digest:", hash),
    res
  )

  # write file to disk
  writeLines(output, outpath)
}


