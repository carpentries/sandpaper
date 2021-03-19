#' Fetch GitHub Workflows
#' 
#' This is a wrapper around [usethis::use_github_action()] to download and
#' install github workflow files in your sandpaper lesson.
#'
#' @param path path to the current lesson.
#' @param files a character vector of file names. Defaults to the workflows 
#'    needed for sandpaper to work on github. 
#' @param base the base URL for the workflows
#' @param overwrite if `TRUE` (default), the file(s) will be overwritten.
#' @return the output of [usethis::use_github_action()]
#' @export
#'
#' @note this assumes that you have an active internet connection.
fetch_github_workflows <- function(path = ".", 
  files = c("comment-pr.yaml", "pr-close.yaml", "pull-request.yaml",
    "remove-branch.yaml", "sandpaper-main.yaml"), 
  base = "https://raw.githubusercontent.com/zkamvar/actions/main/workflows/",
  overwrite = TRUE) {

  if (!is_online()) {
    stop("This function requires an internet connection.")
  }

  wf <- fs::path(path, ".github", "workflows")
  wf_exist <- fs::dir_exists(wf)
  for (file in files) {
    # TODO: this is a cowpath that I need to reevaluate usage
    # If overwriting the file, we should remove it to appease the usethis gods
    if (overwrite && wf_exist && fs::file_exists(fs::path(wf, file))) {
      fs::file_delete(fs::path(wf, file))
    }
    url <- paste0(base, "/", file)
    usethis::with_project(path, usethis::use_github_action(url = url))
  }
}
