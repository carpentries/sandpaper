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
build_markdown_vignettes <- function(path = ".", rebuild = FALSE, quiet = FALSE) {

  episode_path <- fs::path(path, "episodes")
  site_path    <- fs::path(path, "site", "vignettes")

  episodes  <- fs::dir_ls(episode_path, regexp = "*R?md")
  artifacts <- fs::dir_ls(episode_path, regexp = "*R?md", invert = TRUE, type = "file", all = TRUE)
  built     <- fs::dir_ls(site_path, glob = "*md")
  any_built <- if (rebuild || length(built) == 0) FALSE else TRUE

  names(episodes)   <- fs::path_ext_remove(fs::path_file(episodes))
  new_hashes        <- tools::md5sum(episodes)
  names(new_hashes) <- names(episodes)

  if (any_built) {
    old_hashes        <- vapply(built, get_hash, character(1))
    names(old_hashes) <- fs::path_ext_remove(fs::path_file(built))
  } else {
    old_hashes <- character(0)
  }

  to_be_built <- data.frame(
    episode = episodes, 
    hash = new_hashes, 
    stringsAsFactors = FALSE
  )

  if (any_built) {
    # Find all new episodes 
    # new  <- setdiff(names(new_hashes), names(old_hashes))
    # new  <- if (length(new) > 0) new %in% names(new_hashes) else TRUE
    # Find all episods that have the same name
    same_name <- intersect(names(old_hashes), names(new_hashes))

    # Only build the episodes that have changed. 
    to_be_built   <- to_be_built[new_hashes %nin% old_hashes[same_name], ]
    to_be_removed <- setdiff(names(old_hashes), names(new_hashes))
  } else {
    to_be_removed <- character(0)
  }

  for (i in seq_len(nrow(to_be_built))) {
    build_single_episode(to_be_built$episode[i], to_be_built$hash[i], quiet = quiet)
  }

  fs::dir_copy(fs::path(episode_path, "data"), fs::path(site_path, "data"), overwrite = TRUE)
  fs::dir_copy(fs::path(episode_path, "files"), fs::path(site_path, "files"), overwrite = TRUE)
  fs::dir_copy(fs::path(episode_path, "extras"), fs::path(site_path, "extras"), overwrite = TRUE)
  fs::dir_copy(fs::path(episode_path, "figures"), fs::path(site_path, "figures"), overwrite = TRUE)
  fs::file_copy(fs::path_abs(artifacts), fs::path(site_path, artifacts), overwrite = TRUE) 

  if (length(to_be_removed)) fs::file_delete(built[to_be_removed])

  invisible(TRUE)
}

build_single_episode <- function(path, hash, env = new.env(), quiet = FALSE) {
  res <- knitr::knit(text = readLines(path, encoding = "UTF-8"), envir = env, quiet = quiet)
  md <- fs::path_ext_set(fs::path_file(path), "md")
  outpath <- fs::path(fs::path_dir(fs::path_dir(path)), "site", "vignettes", md)
  output <- sub(
    "^---",
    paste("---\nsandpaper-digest:", hash),
    res
  )
  writeLines(output, outpath)
}


