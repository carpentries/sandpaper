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

get_resource_list <- function(path, trim = FALSE) {
  root <- root_path(path)
  cfg  <- get_config(root)
  # res  <- rmarkdown::site_resources(
  #   site_dir  = root,
  #   include   = c("*md", include),
  #   exclude   = c("site", exclude),
  #   recursive = TRUE
  # )
  res <- fs::dir_ls(
    root,
    regexp = "*[.](R?md|ipynb)$", # at the moment, we will only recognize Rmd,
                                  # and ipynb files (although we do not support
                                  # the latter at the moment).
    recurse = 1,# only move into the source folders
    type = "file",
    fail = FALSE
  )

  # Remove github-specific files
  gh_files <- c("README", "CONTRIBUTING")
  no_gh    <- fs::path_ext_remove(fs::path_file(res)) %nin% gh_files
  res      <- res[no_gh]

  # Split the files into a list.
  if (trim) {
    res <- fs::path_rel(res, root)
    res <- split(res, fs::path_dir(res))
  } else {
    res <- split(res, fs::path_rel(fs::path_dir(res), root))
  }

  # These are the only four items that we need to consider order for. 
  for (i in c("episodes", "learners", "instructors", "profiles")) {
    config_order <- cfg[[i]]
    # If the configuration is not missing, then we have to rearrange the order.
    if (!is.null(config_order)) {
      paths         <- res[[i]]
      default_order <- fs::path_file(paths)
      res[[i]]      <- paths[match(config_order, default_order, nomatch = 0)]
    }
  }
  res[names(res) != "site"]
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

