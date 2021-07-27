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

#' Get the full resource list of markdown files
#'
#' @param path path to the lesson
#' @param trim if `TRUE`, trim the paths to be relative to the lesson directory.
#'   Defaults to `FALSE`, which will return the absolute paths
#' @param subfolder the subfolder to check. If this is `NULL`, all folders will
#'   checked and returned (default), otherwise, this should be a string
#'   specifying the folder name in the lesson (e.g. "episodes").
#' @param warn if `TRUE` and `subfolder = "episodes"`, a message is issued to
#'   the user if the episodes field of the configuration file is empty.
#' @return a list of files by subfolder in the order they should appear in the
#'   menu.
#' @keywords internal
#' @seealso [build_status()]
get_resource_list <- function(path, trim = FALSE, subfolder = NULL, warn = FALSE) {
  root <- root_path(path)
  root_path <- root
  recurse <- 1L
  cfg  <- get_config(root)
  should_warn <- warn && is.null(cfg[["episodes"]])
  use_subfolder <- !is.null(subfolder) &&
    length(subfolder) == 1L &&
    is.character(subfolder)

  # Using a subfolder should return a vector of files, but we need to check for
  # a few things first:
  #
  #  1. If the user has an old version of the lesson, we forgive them and use a
  #     more current version
  #  2. Check that the subfolder actually exists in the config file
  #  3. Warn if the episode order has not been set.
  if (use_subfolder) {
    is_episodes <- subfolder == "episodes"
    old_version <- is_episodes && "schedule" %in% names(cfg)

    if (old_version) {
      names(cfg)[names(cfg) == "schedule"] <- "episodes"
    }

    subfolder_exists <- subfolder %in% names(cfg)
    if (!subfolder_exists) {
      stop(glue::glue(
        "{subfolder} is not listed in {fs::path(root, 'config.yaml')}"
      ), call. = FALSE)
    }

    should_warn <- should_warn && is_episodes

    recurse   <- FALSE
    root_path <- fs::path(root, subfolder)
  }

  if (should_warn) warn_schedule()

  res <- fs::dir_ls(
    root_path,
    regexp = "*[.](R?md|ipynb)$", # at the moment, we will only recognize Rmd,
                                  # and ipynb files (although we do not support
                                  # the latter at the moment).
    recurse = recurse, # only move into the source folders
    type = "file",
    fail = FALSE
  )

  # Remove github-specific files
  gh_files <- c("README", "CONTRIBUTING")
  no_gh    <- fs::path_ext_remove(fs::path_file(res)) %nin% gh_files
  res      <- res[no_gh]

  # Split the files into a list.
  if (trim) {
    res <- fs::path_rel(res, root_path)
    res <- split(res, fs::path_dir(res))
  } else {
    res <- split(res, fs::path_rel(fs::path_dir(res), root))
  }

  if (use_subfolder) {
    names(res) <- subfolder
  } else {
    subfolder <- c("episodes", "learners", "instructors", "profiles")
  }

  # These are the only four items that we need to consider order for.
  for (i in subfolder) {
    config_order <- cfg[[i]]
    # If the configuration is not missing, then we have to rearrange the order.
    if (!is.null(config_order)) {
      # Confirm that the order exists
      paths         <- res[[i]]
      default_order <- fs::path_file(paths)
      res[[i]]      <- paths[match(config_order, default_order, nomatch = 0)]
    }
  }
  if (use_subfolder) res[[subfolder]] else res[names(res) != "site"]
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

