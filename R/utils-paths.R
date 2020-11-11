root_path <- function(path) rprojroot::find_root(rprojroot::is_git_root, path)
no_readme <- function() "(?<![/]README)([.]md)$"

dir_available <- function(path) {
  !fs::dir_exists(path) || nrow(fs::dir_info(path)) == 0L
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

path_site <- function(path) {
  home <- root_path(path)
  fs::path(home, "site")
}

path_config <- function(path) {
  home <- root_path(path)
  fs::path(home, "config.yaml")
}

path_site_yaml <- function(path) {
  fs::path(path_site(path), "_pkgdown.yaml")
}

path_built <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "site", "built")
}

path_episodes <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "episodes")
}

path_extras <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "extras")
}

get_source_files <- function(path) {
  pe <- enforce_dir(path_episodes(path))
  fs::dir_ls(pe, regexp = "*R?md")
}

get_built_files <- function(path) {
  pb <- enforce_dir(path_built(path))
  fs::dir_ls(pb, regexp = no_readme(), perl = TRUE)
}

get_source_buddy <- function(path) {
  slug <- get_slug(path)
  # Returns nothing if the pattern cannot be found
  fs::dir_ls(path_episodes(path), regexp = paste0(slug, "[.]R?md"))
}

get_built_buddy <- function(path) {
  slug <- get_slug(path)
  # Returns nothing if the pattern cannot be found
  fs::dir_ls(path_built(path), regexp = paste0(slug, ".md"), fixed = TRUE)
}

get_slug <- function(path) {
  fs::path_ext_remove(fs::path_file(path))
}

get_artifact_files <- function(path) {
  pe <- enforce_dir(path_episodes(path))
  fs::dir_ls(pe,
    regexp = "*R?md", 
    invert = TRUE, 
    type = "file", 
    all = TRUE
  )
}

