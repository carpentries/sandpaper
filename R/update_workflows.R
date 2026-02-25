#nocov start

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
#' @param branch if specified, the branch from which to pull the workflows.
#' @return the paths to the new files.
#' @export
update_github_workflows <- function(path = ".", files = "", overwrite = TRUE, clean = "*.yaml", quiet = FALSE, branch = "") {

  wf <- fs::path(path, ".github", "workflows")

  # get latest version from github carpentries/workbench-workflows releases list
  version_file <- fs::path(wf, "workflows-version.txt")

  if (branch != "") {
    releases_url <- paste0("https://api.github.com/repos/carpentries/workbench-workflows/branches/", branch)
    releases_json <- jsonlite::fromJSON(releases_url)
    latest_version_sha <- releases_json$commit$sha
    latest_version <- strtrim(latest_version_sha, 6)
  } else {
    releases_url <- "https://api.github.com/repos/carpentries/workbench-workflows/releases/latest"
    releases_json <- jsonlite::fromJSON(releases_url)
    latest_version_tag <- releases_json$tag_name
    body <- releases_json$body
    latest_version <- package_version(gsub("^v", "", latest_version_tag))
  }

  need_dir <- !fs::dir_exists(wf)
  if (need_dir) {
    fs::dir_create(wf, recurse = TRUE)
  }
  if (fs::file_exists(version_file)) {
    # if version is not semver, set to 0.0.0 to force update
    oldvers <- tryCatch(
      package_version(readLines(version_file)),
      error = function(e) package_version("0.0.0")
    )
  } else {
    oldvers <- package_version("0.0.0")
  }

  if (overwrite || branch != "" || oldvers < latest_version) {
    if (files == "" && !is.null(clean)) {
      fs::file_delete(fs::dir_ls(wf, glob = clean))

      # if sandpaper-version.txt file exists, delete it
      sandpaper_version_file <- fs::path(wf, "sandpaper-version.txt")
      if (fs::file_exists(sandpaper_version_file)) {
        fs::file_delete(sandpaper_version_file)
      }
    }
    # we update the files
    if (branch != "") {
      zip_url <- paste0("https://github.com/carpentries/workbench-workflows/archive/refs/heads/", branch, ".zip")
    }
    else {
      zip_url <- releases_json$zipball_url
    }
    if (!quiet) {
      cli::cli_alert_info("Downloading workflows from {releases_url}")
    }
    temp_zip <- fs::file_temp(ext = ".zip")
    httr::GET(zip_url, httr::write_disk(temp_zip, overwrite = TRUE))
    temp_dir <- fs::dir_create(fs::file_temp())
    utils::unzip(temp_zip, exdir = temp_dir)
    latest_files <- fs::dir_ls(temp_dir, recurse = TRUE, glob = "*workflows/*")

    our_files <- fs::dir_ls(wf)
    new_files <- character(length(latest_files))
    names(new_files) <- latest_files
    for (file in latest_files) {
      is_present <- fs::file_exists(fs::path(wf, fs::path_file(file)))
      if (!is_present || overwrite) {
        new_files[file] <- fs::file_copy(file, wf, overwrite = overwrite)
      }
    }
  } else {
    new_files <- character(0)
  }
  writeLines(as.character(latest_version), con = version_file)
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
#nocov end
