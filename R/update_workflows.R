#' Update github workflows
#'
#' This function copies and updates the workflows to run `{sandpaper}`. 
#'
#' @param path path to the current lesson.
#' @param files the files to include in the update. Defaults to an empty string, 
#'   which will update all files
#' @param overwrite if `TRUE` (default), the file(s) will be overwritten.
#' @param clean glob of files to be cleaned before writing. Defaults to
#'   `"*.yaml"`.  to remove all files with the four-letter "yaml" extension
#'   (but it will not remove the ".yml" extension). You can also specify a
#'   whole file name like "workflow.yaml" to remove one specific file. If you
#'   do not want to clean, set this to `NULL`.
#' @param quiet if `TRUE`, the process will not output any messages, default is
#'   `FALSE`, which will report on the progress of each step.
#' @return the paths to the new files. 
#' @export
update_github_workflows <- function(path = ".", files = "", overwrite = TRUE, clean = "*.yaml", quiet = FALSE) {

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
    if (files == "" && !is.null(clean)) {
      fs::file_delete(fs::dir_ls(wf, glob = clean))
    }
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
  } else {
    new_files <- character(0)
  }
  writeLines(as.character(this_version), con = version_file)
  if (!quiet) {
    thm <- cli::cli_div(theme = sandpaper_cli_theme())
    if (length(new_files) && !all(new_files == "")) {
      changed <- gert::git_status(repo = path)
      workflows <- fs::path_dir(changed$file) == ".github/workflows"
      if (any(workflows)) {
        cli::cli_alert_info("Workflows/files updated:")
      } else {
        cli::cli_alert_info("Workflows up-to-date!")
      }
      msg <- glue::glue_data(changed[workflows, , drop = FALSE],
        "{.file ^file$} {.emph (^status$)}", .open = "^", .close = "$")
      cli::cli_li(msg)
    } else {
      cli::cli_alert_info("Workflows up-to-date!")
    }
    cli::cli_end(thm)
  }
  return(invisible(new_files[new_files != ""]))
}


