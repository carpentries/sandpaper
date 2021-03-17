#' Fetch GitHub Workflows
#' 
#' This is a wrapper around [usethis::use_github_action()] to download and
#' install github workflow files in your sandpaper lesson.
#'
#' @param files a character vector of file names 
#' @param base the base URL for the workflows
#' @return the output of [usethis::use_github_action()]
#'
#' @note this assumes that you have an active internet connection.
fetch_github_workflows <- function(files = c("comment-pr.yaml",
    "pr-close.yaml", "pull-request.yaml", "remove-branch.yaml",
    "sandpaper-main.yaml"), 
  base = "https://raw.githubusercontent.com/zkamvar/actions/main/workflows/") {

  if (!is_online()) {
    stop("This function requires an internet connection.")
  }
  purrr::walk(paste0(base, "/", files), ~usethis::use_github_action(url = .x))
}
