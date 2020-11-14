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

path_learners <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "learners")
}

path_instructors <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "instructors")
}

path_profiles <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "profiles")
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

