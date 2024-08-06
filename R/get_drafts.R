#' Show files in draft form
#'
#' By default, `{sandpaper}` will use the files in alphabetical order as they are
#' presented in the folders, however, it is **strongly** for authors to specify
#' the order of the files in their lessons, so that it's easy to rearrange or
#' add, split, or rearrange files. 
#'
#' This mechanism also allows authors to work on files in a draft form without
#' them being published. This function will list and show the files in draft for
#' automation and audit.
#'
#' @param path path to the the sandpaper lesson
#' @param folder the specific folder for which to list the draft files. Defaults
#'   to `NULL`, which indicates all folders listed in `config.yaml`.
#' @param message if `TRUE` (default), an informative message about the files
#'   that are in draft status are printed to the screen.
#' @export
#'
#' @return a vector of paths to files in draft and a message (if specified)
get_drafts <- function(path, folder = NULL, message = getOption("sandpaper.show_draft", TRUE)) {
  cfg <- get_config(path)
  if (is.null(folder)) {
    folder <- c("episodes", "learners", "instructors", "profiles")
  }
  res <- character(0)
  for (f in folder) {
    if (is.null(cfg[[f]])) {
      if (message) message_default_draft(f)
      next
    }
    drafts <- get_sources(path, f)
    if (any(in_draft <- fs::path_file(drafts) %nin% cfg[[f]])) {
      if (message) message_draft_files(cfg[[f]], fs::path_file(drafts), f)
      res <- c(res, drafts[in_draft])
    } else {
      if (message) message_no_draft(f)
    }
  }
  fs::path(res)
}
