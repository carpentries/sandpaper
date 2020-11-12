# All of these helper functions target the source of the lesson... that is, all
# of the files that git tracks. 
path_config <- function(path) {
  home <- root_path(path)
  fs::path(home, "config.yaml")
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

