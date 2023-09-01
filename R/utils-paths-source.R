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


provide_setup <- function(cfg, setup = "setup.md") {
  if (is.null(cfg) || is.null(cfg$learners)) {
    return(cfg)
  }
  if (get_slug(setup) %nin% get_slug(cfg$learners)) {
    cfg$learners <- c(cfg$learners, setup)
  }
  return(cfg)
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
    regexp = "*[.](R?md|lock|yaml)$",
    recurse = recurse, # only move into the source folders
    type = "file",
    fail = FALSE
  )

  # Remove github-specific files
  gh_files <- c("README", "CONTRIBUTING")
  no_gh    <- fs::path_ext_remove(fs::path_file(res)) %nin% gh_files
  res      <- res[no_gh]

  # Add the lockfile if needed
  if (getOption("sandpaper.use_renv")) {
    op <- Sys.getenv("RENV_PROFILE")
    on.exit(Sys.setenv("RENV_PROFILE" = op))
    Sys.setenv("RENV_PROFILE" = "lesson-requirements")
    wd <- getwd()
    on.exit(setwd(wd), add = TRUE)
    setwd(root)
    res <- c(res, renv::paths$lockfile(project = root))
  }

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
    lrn <- res[["learners"]]
    stp <- fs::path_file(lrn[get_slug(lrn) %in% "setup"])
    cfg <- provide_setup(cfg, stp)
    subfolder <- c("episodes", "learners", "instructors", "profiles")
  }

  # These are the only four items that we need to consider order for.
  for (i in subfolder) {
    # If the configuration is not missing, then we have to rearrange the order.
    res[[i]] <- parse_file_matches(reality = res[[i]], hopes = cfg[[i]],
      warn = warn, subfolder = i)
  }
  if (use_subfolder) res[[subfolder]] else res[names(res) != "site"]
}

get_sources <- function(path, subfolder = "episodes") {
  pe <- enforce_dir(fs::path(root_path(path), subfolder))
  fs::path_abs(fs::dir_ls(pe, regexp = "*R?md"))
}

get_source_artifacts <- function(path, subfolder = "episodes") {
  pe <- enforce_dir(fs::path(root_path(path), subfolder))
  fs::dir_ls(pe, regexp = "*R?md",
    invert = TRUE,
    type = "file",
    all = TRUE
  )
}

#' Subset file matches to the order they appear in the config file
#'
#' @param reality a list of paths that exist in the lesson
#' @param hopes a list of files in the order they should appear in the lesson
#' @param warn a boolean. If `TRUE` and the `sandpaper.show_draft` option is
#'   set to TRUE, then the files that are not in `hopes` are shown to the
#'   screen as drafts
#' @param subfolder a character. The folder where we should find the files in
#'   `hopes`. This is only used for creating an error message.
#' @return a character vector of `reality` subset in the order of `hopes`
#' @keywords internal
#' @examples
#' # setup ----------------------------------------------------
#' #
#' # NOTE: we need to define our namespace here because using `:::`
#' # in example calls is illegal.
#' snd <- asNamespace("sandpaper")
#' print(need <- c("a", "bunch", "of", "silly", "files"))
#' print(exists <- fs::path("path", "to", sample(need)))
#'
#' # Rearrange files ------------------------------------------
#' snd$parse_file_matches(reality = exists, hopes = need,
#'   subfolder = "episodes")
#'
#' # a subset of files ----------------------------------------
#' snd$parse_file_matches(reality = exists,
#'   hopes = need[4:5], subfolder = "episodes")
#'
#' # a subset of files with a warning -------------------------
#' op <- getOption("sandpaper.show_draft")
#' options(sandpaper.show_draft = TRUE)
#' on.exit(options(sandpaper.show_draft = op))
#' snd$parse_file_matches(reality = exists,
#'   hopes = need[-(4:5)], warn = TRUE, subfolder = "episodes")
#'
#' # files that do not exist give an error --------------------
#' try(snd$parse_file_matches(reality = exists,
#'   hopes = c("these", need[4:5]), subfolder = "episodes"))
parse_file_matches <- function(reality, hopes = NULL, warn = FALSE, subfolder) {
  if (is.null(hopes) || is.null(reality)) {
    return(reality)
  }
  real_files <- fs::path_file(reality)
  # Confirm that the order exists
  matches <- match(hopes, real_files, nomatch = 0)

  missing_config <- any(matches == 0)

  if (missing_config) {
    error_missing_config(hopes, real_files, subfolder)
  }

  show_drafts <- warn && getOption("sandpaper.show_draft", FALSE)

  if (show_drafts) {
    message_draft_files(hopes, real_files, subfolder)
  }

  reality[matches]
}
