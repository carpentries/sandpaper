#' Return a function that loads snippet files from the given directories.
#' This will be used to create a `snippets()` function in the episode build environment.
#'
#' @param custom_snippets the path to the custom snippets directory (or `NULL` if none)
#' @param base_snippets the path to the base snippets directory (or `NULL` if none)
#' @return a function that takes a child file path and renders it as a snippet, or returns the path to the snippet file if `render = FALSE`.
#' @keywords internal
bootstrap_snippet_loader <- function(custom_snippets, base_snippets = NULL) {
  # make sure both variables are evaluated now, so that the returned function has them in its closure
  force(custom_snippets)
  force(base_snippets)

  function(child_file, render = TRUE) {
    doc_paths <- c(
      if (!is.null(custom_snippets)) fs::path(custom_snippets, child_file) else character(0),
      if (!is.null(base_snippets)) fs::path(base_snippets, child_file) else character(0)
    )
    doc_paths <- unique(doc_paths)
    existing <- doc_paths[fs::file_exists(doc_paths)]

    if (!length(existing)) {
      stop(
        "Snippet not found: ", child_file,
        "\nPaths checked: ", paste(doc_paths, collapse = "\n"),
        call. = FALSE
      )
    }

    path <- existing[[1]]
    if (isTRUE(render)) {
      cat(knitr::knit_child(path, quiet = TRUE))
      return(invisible(NULL))
    }

    path
  }
}

resolve_snippet_dir <- function(snippets, root) {
  snippets <- if (is.character(snippets) && length(snippets) == 1L) trimws(snippets) else ""
  if (!nzchar(snippets)) {
    stop("'snippets' value is missing in snippets configuration", call. = FALSE)
    return(NULL)
  }

  # Accept both styles:
  # 1) config name (e.g. "HPCC_MagicCastle_slurm")
  # 2) explicit path (e.g. "episodes/files/customization/YourCustomSnippets/snippets")
  snippet_paths <- unique(c(
    fs::path(path_customization(root), snippets, "snippets"),
    snippets
  ))

  exists <- snippet_paths[fs::dir_exists(snippet_paths)]
  if (!length(exists)) {
    stop(
    "Snippet directory not found for snippets: ", snippets,
    "\nPaths checked\n: ", paste(snippet_paths),
    call. = FALSE
    )
    return(NULL)
  }

  fs::path_abs(exists[[1]])
}

drop_null_fields <- function(x) {
  if (!is.list(x)) {
    return(x)
  }

  x <- lapply(x, drop_null_fields)
  x[!vapply(x, is.null, logical(1))]
}

get_lesson_customization <- function(path, env_var = "CUSTOM_SNIPPETS", quiet = TRUE) {
  root <- tryCatch(root_path(path), error = function(...) NULL)
  if (is.null(root)) {
    return(NULL)
  }

  lesson_config <- yaml::read_yaml(path_config(root), eval.expr = FALSE)
  if (is.null(lesson_config$base_snippets) || !nzchar(lesson_config$base_snippets)) {
    return(NULL)
  }

  base_name <- normalize_snippets_config_name(lesson_config$base_snippets)
  if (is.null(base_name)) {
    return(NULL)
  }

  base_paths <- snippets_config_paths(base_name, root)
  base_exists <- base_paths[fs::file_exists(base_paths)]
  if (!length(base_exists)) {
    return(NULL)
  }
  base_cfg <- base_exists[[1]]
  if (!quiet) {
    cli::cli_alert_info("Using base snippets config: {base_cfg}")
  }

  custom_snippets_path <- Sys.getenv(env_var, unset = lesson_config$custom_snippets %||% "")
  custom_name <- normalize_snippets_config_name(custom_snippets_path)
  has_custom <- !is.null(custom_name)

  base <- read_lesson_yaml(base_cfg, root)
  base_config <- base$config %||% list()
  base_snippet_dir <- resolve_snippet_dir(base_name, root)

  custom_snippet_dir <- base_snippet_dir
  if (has_custom) {
    custom_paths <- snippets_config_paths(custom_name, root)
    custom_exists <- custom_paths[fs::file_exists(custom_paths)]
    if (!length(custom_exists)) {
      stop("YAML file not found: ", fs::path(path_customization(root), custom_name, "_config_options.yml"), call. = FALSE)
    }
    custom_snippets <- custom_exists[[1]]
    if (!quiet) {
      cli::cli_alert_info("Using custom snippets config: {custom_snippets}")
    }

    custom <- read_lesson_yaml(custom_snippets, root)
    custom_config <- drop_null_fields(custom$config %||% list())
    base_config <- utils::modifyList(base_config, custom_config)
    custom_snippet_dir <- resolve_snippet_dir(custom_name, root)
  }

  list(
    config = base_config,
    snippets = bootstrap_snippet_loader(custom_snippet_dir, base_snippet_dir),
    snippets_custom = custom_snippet_dir,
    snippets_base = base_snippet_dir
  )
}

valid_snippet_features <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  any(grepl("`r\\s*config\\$|\\bsnippets\\s*\\(", lines, perl = TRUE))
}

#' Compute a combined hash over all active snippet config and snippet files
#'
#' @param path the path to an episode or lesson directory
#' @return a single string hash that changes whenever:
#' - The active base or custom snippets config YAML changes
#' - Any file inside the active snippet directories changes
#' - The `base_snippets` or `custom_snippets` keys in config.yaml change
#'   (because `get_lesson_customization()` re-reads config.yaml)
#'
#' Returns `NULL` when snippets are not configured.
#' @keywords internal
get_snippets_hash <- function(path) {
  root <- tryCatch(root_path(path), error = function(...) NULL)
  if (is.null(root)) {
    return(NULL)
  }

  lesson_config <- tryCatch(
    yaml::read_yaml(path_config(root), eval.expr = FALSE),
    error = function(...) NULL
  )
  if (is.null(lesson_config) || is.null(lesson_config$base_snippets) || !nzchar(lesson_config$base_snippets)) {
    return(NULL)
  }

  # Collect the active config YAML files
  base_name   <- normalize_snippets_config_name(lesson_config$base_snippets)
  custom_name <- normalize_snippets_config_name(Sys.getenv("CUSTOM_SNIPPETS", unset = ""))
  if (is.null(custom_name)) {
    custom_name <- normalize_snippets_config_name(lesson_config$custom_snippets)
  }

  config_files <- character(0)
  for (nm in c(base_name, custom_name)) {
    if (!is.null(nm)) {
      paths <- snippets_config_paths(nm, root)
      config_files <- c(config_files, paths[fs::file_exists(paths)])
    }
  }

  # Also include the relevant lines from config.yaml itself so that changing
  # base_snippets / custom_snippets invalidates the hash
  snippet_keys <- paste(
    lesson_config$base_snippets %||% "",
    lesson_config$custom_snippets %||% "",
    sep = "\n"
  )

  # Collect all files inside the active snippet directories
  snippet_dirs <- character(0)
  for (nm in c(base_name, custom_name)) {
    if (!is.null(nm)) {
      d <- fs::path(path_customization(root), nm, "snippets")
      if (fs::dir_exists(d)) {
        snippet_dirs <- c(snippet_dirs, d)
      }
    }
  }
  snippet_files <- unlist(lapply(snippet_dirs, function(d) {
    as.character(fs::dir_ls(d, recurse = TRUE, type = "file"))
  }))

  all_files <- unique(c(config_files, snippet_files))
  if (!length(all_files)) {
    return(NULL)
  }

  file_hashes <- unname(tools::md5sum(all_files))
  rlang::hash(c(file_hashes, snippet_keys))
}

missing_snippets_config_error <- function(path) {
  root <- root_path(path)
  paste0(
    "Episode uses snippet/config placeholders (`config$...` or `snippets()`), ",
    "but top-level lesson config.yaml must set a valid `base_snippets` folder in ",
    path_customization(root),
    ". Optionally also set `custom_snippets` in config.yaml or use the ",
    "CUSTOM_SNIPPETS environment variable to override, in ",
    path_config(root)
  )
}
