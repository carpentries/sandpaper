# The .build_paths environment will allow me to pass around a defined set of
# build paths for the session. This way, I don't have to worry about juggling
# paths based on roots. I can set them at the top of the user-facing functions.
.build_paths <- new.env()

reset_build_paths <- function() {
  .build_paths$source   <- NULL
}

init_source_path <- function(path) {
  if (!dir_available(path)) {
    stop(glue::glue("{path} is not an empty directory."), call. = FALSE)
  }
  gert::git_init(path)
  check_git_user(path)
  reset_build_paths()
  .build_paths$source <- path
  invisible(.build_paths)
}

# NOTE: rethink this.... do we want to have a hard-to-reset option here?
set_source_path <- function(path) {
  .build_paths$source <- root_path(path) %||% .build_paths$source
  invisible(.build_paths$source)
}

get_source_path <- function() {
  .build_paths$source
}
