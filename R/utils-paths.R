root_path <- function(path) rprojroot::find_root(rprojroot::is_git_root, path)
no_readme <- function() "(?<![/]README)([.]md)$"

dir_available <- function(path) {
  !fs::dir_exists(path) || nrow(fs::dir_info(path)) == 0L
}

make_here <- function(ROOT) {
  force(ROOT)
  function(leaf = "") fs::path(ROOT, leaf)
}

path_site <- function(path) {
  home <- root_path(path)
  fs::path(home, "site")
}

path_site_yaml <- function(path) {
  fs::path(path_pkgdown(path), "_pkgdown.yml")
}

path_pkgdown <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "site")#, "vignettes")
}

path_episodes <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "episodes")
}

get_source_files <- function(path) {
  fs::dir_ls(path_episodes(path), regexp = "*R?md")
}

get_built_files <- function(path) {
  fs::dir_ls(path_pkgdown(path), regexp = no_readme(), perl = TRUE)
}

get_episode_slug <- function(path) {
  fs::path_ext_remove(fs::path_file(path))
}

get_artifact_files <- function(path) {
  
  fs::dir_ls(path_episodes(path), 
    regexp = "*R?md", 
    invert = TRUE, 
    type = "file", 
    all = TRUE
  )
}
