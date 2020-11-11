root_path <- function(path) rprojroot::find_root(rprojroot::is_git_root, path)
no_readme <- function() "(?<![/]README)([.]md)$"
.build_paths <- new.env()
.build_paths$markdown <- NULL
.build_paths$html     <- NULL

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

get_sources <- function(path, subfolder = "episodes") {
  pe <- enforce_dir(fs::path(root_path(path), subfolder))
  fs::dir_ls(pe, regexp = "*R?md")
}

get_artifacts <- function(path, subfolder = "episodes") {
  pe <- enforce_dir(fs::path(root_path(path), subfolder))
  fs::dir_ls(pe, regexp = "*R?md", 
    invert = TRUE, 
    type = "file", 
    all = TRUE
  )
}

get_episode_sources <- function(path) {
  get_sources(path, "episodes")
}

get_episode_artifacts <- function(path) {
  get_artifacts(path, "episodes")
}

get_extra_sources <- function(path) {
  get_sources(path, "extras")
}

get_extra_artifacts <- function(path) {
  get_artifacts(path, "extras")
}

get_markdown_files <- function(path) {
  pb <- enforce_dir(path)
  fs::dir_ls(pb, regexp = no_readme(), perl = TRUE, recurse = TRUE)
}

get_built_buddy <- function(path) {
  # slug <- get_slug(path)
  pat <- fs::path_ext_set(get_slug(path), "md")
  # Returns nothing if the pattern cannot be found
  fs::dir_ls(path_built(path), regexp = pat, fixed = TRUE)
}

get_slug <- function(path) {
  fs::path_ext_remove(fs::path_file(path))
}


