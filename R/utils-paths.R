root_path <- function(path) {
  criteria <- rprojroot::has_dir("episodes") |
    rprojroot::has_dir("site") |
    rprojroot::has_dir("learners") |
    rprojroot::has_dir("instructors") |
    rprojroot::has_dir("profiles")

  rprojroot::find_root(criteria, path)
}

no_readme <- function() "(?<![/]README)([.]md)$"

dir_available <- function(path) {
  !fs::dir_exists(path) || nrow(fs::dir_info(path)) == 0L
}

get_slug <- function(path) {
  fs::path_ext_remove(fs::path_file(path))
}

make_here <- function(ROOT) {
  force(ROOT)
  function(...) fs::path(ROOT, ...)
}

# creates a directory if it doesn't exist
enforce_dir <- function(paths) {
  to_create <- !fs::dir_exists(paths)
  if (any(to_create)) {
    fs::dir_create(paths[to_create])
  }
  invisible(paths)
}

path_site <- function(path = NULL) {
  sitepath <- Sys.getenv("SANDPAPER_SITE")
  if (nzchar(sitepath)) {
    return(fs::path_real(sitepath))
  }
  if (is.null(path)) {
    fs::path(.build_paths$source, "site")
  } else {
    fs::path(root_path(path), "site")
  }
}

path_site_yaml <- function(path = NULL) {
  fs::path(path_site(path), "_pkgdown.yaml")
}

path_built <- function(inpath = NULL) {
  fs::path(path_site(inpath), "built")
}

get_markdown_files <- function(path = NULL) {
  fs::dir_ls(
    path_built(path),
    regexp = no_readme(),
    perl = TRUE,
    recurse = TRUE
  )
}

