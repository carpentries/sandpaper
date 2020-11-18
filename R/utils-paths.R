root_path <- function(path) {
  rprojroot::find_root(rprojroot::has_dir("episodes"), path)
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
enforce_dir <- function(path) {
  if (!fs::dir_exists(path)) {
    fs::dir_create(path)
  }
  invisible(path)
}

path_site <- function(path = NULL) {
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

get_built_buddy <- function(path) {
  pat <- fs::path_ext_set(get_slug(path), "md")
  # Returns nothing if the pattern cannot be found
  fs::dir_ls(path_built(path), regexp = pat, fixed = TRUE)
}



