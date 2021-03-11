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

# TODO: configure this so that it gives me the full relative path of the
# resources. 
get_resource_list <- function(path, include = character(0), exclude = character(0), trim = FALSE) {
  root <- root_path(path)
  cfg  <- get_config(root)
  res  <- rmarkdown::site_resources(
    site_dir  = root,
    include   = c("*md", include),
    exclude   = c("site", exclude),
    recursive = TRUE
  )
  # Get the full path if trim is FALSE
  res <- if (trim) res else fs::path(root, res)

  res <- split(res, fs::path_rel(fs::path_dir(res), root))
  # At the moment, these are the only four items that we need to consider order
  # for. 
  for (i in c("episodes", "learners", "instructors", "profiles")) {
    config_order <- cfg[[i]]
    # If the configuration is not missing, then we have to rearrange the order.
    if (!is.null(config_order)) {
      paths         <- res[[i]]
      default_order <- fs::path_file(paths)
      res[[i]]      <- paths[match(config_order, default_order, nomatch = 0)]
    }
  }
  res
}

get_sources <- function(path, subfolder = "episodes") {
  pe <- enforce_dir(fs::path(root_path(path), subfolder))
  fs::path_abs(fs::dir_ls(pe, regexp = "*R?md"))
}

get_artifacts <- function(path, subfolder = "episodes") {
  pe <- enforce_dir(fs::path(root_path(path), subfolder))
  fs::dir_ls(pe, regexp = "*R?md", 
    invert = TRUE, 
    type = "file", 
    all = TRUE
  )
}

