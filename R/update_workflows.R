#' Update github workflows
#'
#' This function copies and updates the workflows to run {sandpaper}. 
#'
#' @param path path to the current lesson.
#' @param files the files to include in the update. Defaults to an empty string, 
#'   which will update all files
#' @param overwrite if `TRUE` (default), the file(s) will be overwritten.
#' @return the paths to the new files. 
#' @export
#'
#' @note this assumes that you have an active internet connection.
update_github_workflows <- function(path = ".", files = "", overwrite = TRUE) {

  if (!pingr::is_online()) {
    stop("This function requires an internet connection.")
  }

  wf <- fs::path(path, ".github", "workflows")
  version_file <- fs::path(wf, "sandpaper-version.txt")
  this_version <- package_version(utils::packageDescription("sandpaper")$Version)

  need_dir <- !fs::dir_exists(wf)
  if (need_dir) {
    fs::dir_create(wf, recurse = TRUE)
  }
  if (fs::file_exists(version_file)) {
    oldvers <- package_version(readLines(version_file))
  } else {
    oldvers <- package_version("0.0.0")
  }

  if (overwrite || oldvers < this_version) {
    # we update the files
    our_files <- system.file("workflows", files, package = "sandpaper")
    if (length(our_files) == 1L && fs::is_dir(our_files)) {
      our_files <- fs::dir_ls(our_files)
    }
    new_files <- character(length(our_files))
    names(new_files) <- our_files
    for (file in our_files) {
      is_present <- fs::file_exists(fs::path(wf, fs::path_file(file)))
      if (!is_present || overwrite) {
        new_files[file] <- fs::file_copy(file, wf, overwrite = overwrite)
      }
    }
  }
  writeLines(as.character(this_version), con = version_file)
  return(invisible(new_files[new_files != ""]))
}


