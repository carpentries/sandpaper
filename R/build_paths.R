# The .build_paths environment will allow me to pass around a defined set of
# build paths for the session. This way, I don't have to worry about juggling
# paths based on roots. I can set them at the top of the user-facing functions.
.build_paths <- new.env()

reset_build_paths <- function() {
  .build_paths$source   <- NULL
  .build_paths$markdown <- NULL
  .build_paths$site     <- NULL
}

init_source_path <- function(path) {
  if (!dir_available(path)) {
    stop(glue::glue("{path} is not an empty directory."), call. = FALSE)
  }
  gert::git_init(path)
  check_git_user(path)
  reset_build_paths()
  set_local_build(path)
}


# NOTE: rethink this.... do we want to have a hard-to-reset option here?
set_source_path <- function(path) {
  .build_paths$source <- .build_paths$source %||% root_path(path)
  invisible(.build_paths$source)
}

set_markdown_path <- function(path) {
  .build_paths$markdown <- .build_paths$markdown %||% path
  invisible(.build_paths$markdown)
}

set_site_path <- function(path) {
  .build_paths$site <- .build_paths$site %||% path
  invisible(.build_paths$site)
}

# Local builds are the most common and have the site live inside of 
# the `site/` directory. 
set_local_build <- function(path) {
  root <- set_source_path(path)
  set_markdown_path(fs::path(root, "site", "built"))
  set_site_path(fs::path(root, "site"))
  invisible(as.list(.build_paths))
}

set_ci_build <- function(path) {
  root <- set_source_path(path)
  set_markdown_path(fs::path(root, "..", "md-source"))
  set_site_path(fs::path(root, "..", "gh-pages"))
  invisible(as.list(.build_paths))
}
