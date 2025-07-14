#' Set the order of items in a dropdown menu
#'
#' @param path path to the lesson. Defaults to the current directory.
#' @param order the files in the order presented (with extension)
#' @param write if `TRUE`, the schedule will overwrite the schedule in the
#'   current file.
#' @param folder one of four folders that sandpaper recognises where the files
#'   listed in `order` are located: episodes, learners, instructors, profiles.
#'
#' @export
#' @rdname set_dropdown
#' @examples
#'
#' tmp <- tempfile()
#' create_lesson(tmp, "test lesson", open = FALSE, rmd = FALSE)
#' # Change the title and License
#' set_config(c(title = "Absolutely Free Lesson", license = "CC0"),
#'   path = tmp,
#'   write = TRUE
#' )
#' create_episode("using-R", path = tmp, open = FALSE)
#' print(sched <- get_episodes(tmp))
#'
#' # reverse the schedule
#' set_episodes(tmp, order = rev(sched))
#' # write it
#' set_episodes(tmp, order = rev(sched), write = TRUE)
#'
#' # see it
#' get_episodes(tmp)
#'
set_dropdown <- function(path = ".", order = NULL, write = FALSE, folder) {
  check_order(order, folder)
  real_files <- fs::path_file(fs::dir_ls(
    fs::path(path, folder),
    type = "file",
    regexp = "[.]R?md"
  ))
  if (any(!order %in% real_files)) {
    error_missing_config(order, real_files, folder)
  }
  yaml  <- quote_config_items(get_config(path))

  # account for extra items not yet known to our config
  yaml$custom_items <- yaml_list(yaml[!names(yaml) %in% known_yaml_items])
  sched <- yaml[[folder]]
  sched <- if (is.null(sched) && folder == "episodes") yaml[["schedule"]] else sched
  sched_folders <- c("episodes", "learners", "instructors", "profiles")
  if (folder %in% sched_folders) {
    # strip the extension
    yaml[[folder]] <- fs::path_file(order)
  } else {
    yaml[[folder]] <- order
  }
  if (write) {
    # Avoid whisker from interpreting the list incorrectly.
    for (i in sched_folders) {
      yaml[[i]] <- yaml_list(yaml[[i]])
    }
    copy_template("config", path, "config.yaml", values = yaml)
  } else {
    show_changed_yaml(sched, order, yaml, folder)
  }
}

#' Set individual keys in a configuration file
#'
#' @param pairs a named list or character vector with keys as the names and the
#'   new values as the contents
#' @param create if `TRUE`, any new values in `pairs` will be created and
#'   appended; defaults to `FALSE`, which prevents typos from sneaking in.
#'   single key-pair values currently supported.
#' @inheritParams set_dropdown
#'
#' @details
#'
#' This function deals strictly with keypairs in the yaml. For lists, see
#' [set_dropdown()].
#'
#' ### Default Keypairs Known by Sandpaper
#'
#' When you create a new lesson in sandpaper, there are a set of default
#' keypairs that are pre-filled. To make sure contact information and links in
#' the footer are accurate, please modify these values.
#'
#' - **carpentry** `[character]` one of cp, dc, swc, lab, incubator
#' - **title** `[character]` the lesson title (e.g. `'Introduction to R for
#'   Plant Pathologists'`
#' - **created** `[character]` Date in ISO 8601 format (e.g. `'2021-02-09'`)
#' - **keywords** `[character]` comma-separated list (e.g `'static site, R,
#'   tidyverse'`)
#' - **life_cycle** `[character]` one of pre-alpha, alpha, beta, stable
#' - **license** `[character]` a license for the lesson (e.g. `'CC-BY 4.0'`)
#' - **source** `[character]` the source repository URL
#' - **branch** `[character]` the default branch (e.g. `'main'`)
#' - **contact** `[character]` an email address of who to contact for more
#'   information about the lesson
#'
#' ### Optional Keypairs Known by Sandpaper
#'
#' The following keypairs are known by sandpaper, but are optional:
#'
#' - **lang** `[character]` the [language
#'   code](https://www.gnu.org/software/gettext/manual/html_node/Usual-Language-Codes.html)
#'   that matches the language of the lesson content. This defaults to `"en"`,
#'   but can be any language code (e.g. "ja" specifying Japanese) or
#'   combination language code and [country
#'   code](https://www.gnu.org/software/gettext/manual/html_node/Country-Codes.html)
#'   (e.g. "pt_BR" specifies Pourtugese used in Brazil). For more information
#'   on how this is used, see [the Locale Names section of the gettext
#'   manual](https://www.gnu.org/software/gettext/manual/html_node/Locale-Names.html)
#' - **url** `[character]` custom URL if you are deploying to a URL that is not
#'   the default github pages io domain.
#' - **fail_on_error** `[boolean]` for R Markdown lessons; fail the build if any
#'   chunks produce an error. Use `#| error: true` in chunk options to allow the
#'   error to be displayed
#' - **workbench-beta** `[boolean]` if truthy, this displays a banner on the
#'   site that indicates the site is in the workbench beta phase.
#' - **overview** `[boolean]` All lessons must have episodes with the exception
#'   of overview lessons. To indicate that your lesson serves as an overview for
#'   other lessons, use `overview: true`
#' - **handout** `[boolean]` or `[character]` This option instructs `{sandpaper}`
#'   to create a handout of all RMarkdown files via `{pegboard}`, which uses
#'   [knitr::purl()] in the background after removing everything but the
#'   challenges (without solutions) and any code blocks where `purl = TRUE`. The
#'   default path for the handout is `files/code-handout.R`
#'
#'
#' As the workbench becomes more developed, some of these optional keys may
#' disappear.
#'
#' #### Custom Engines
#'
#' To use a specific version of sandpaper or varnish locally, you would install
#' them using `remotes::install_github("carpentries/sandpaper@VERSION")` syntax,
#' but to provision these versions on GitHub, you can provision these in the
#' `config.yaml` file:
#'
#'  - **sandpaper** `[character]` github string or version number of sandpaper
#'    version to use
#'  - **varnish** `[character]` github string or version number of varnish
#'    version to use
#'  - **pegboard** `[character]` github string or version number of pegboard
#'    version to use
#'
#' For example, if you had forked your own version of varnish to modify the
#' colourscheme, you could use:
#'
#' ```
#' varnish: MYACCOUNT/varnish
#' ```
#'
#' If there is a specific branch of sandpaper or varnish that is being tested,
#' and you want to test it on your lesson temporarily, you could use the `@`
#' symbol to refer to the specific branch or commit to use:
#'
#' ```
#' sandpaper: carpentries/sandpaper@BRANCH-NAME
#' varnish: carpentries/varnish@BRANCH-name
#' ```
#'
#'
#' @export
#' @examples
#' if (FALSE) {
#' tmp <- tempfile()
#' create_lesson(tmp, "test lesson", open = FALSE, rmd = FALSE)
#' # Change the title and License (default vars)
#' set_config(c(title = "Absolutely Free Lesson", license = "CC0"),
#'   path = tmp,
#'   write = TRUE
#' )
#'
#' # add the URL and workbench-beta indicator
#' set_config(list("workbench-beta" = TRUE, url = "https://example.com/"),
#'   path = tmp,
#'   create = TRUE,
#'   write = TRUE
#' )
#' }
set_config <- function(pairs = NULL, create = FALSE, path = ".", write = FALSE) {
  keys <- names(pairs)
  values <- pairs
  stopifnot(
    "please supply key/value pairs to use" = length(values) > 0,
    "values must have named keys" = length(keys) > 0,
    "ALL values must have named keys" = !anyNA(keys) && !any(trimws(keys) == "")
  )
  cfg <- path_config(path)
  l <- readLines(cfg)
  what <- vapply(glue::glue("^{keys}:"), function(key, config, create) {
    position <- which(grepl(key, config))
    if (length(position)) {
      return(position)
    } else if (create) {
      return(-9L)
    } else {
      return(0L)
    }
  }, integer(1), config = l, create = create)
  # creates a character vector for the number of keys we need
  line <- character(length(keys))
  for (i in seq(keys)) {
    vali <- values[[i]]
    if (is.logical(vali)) {
      vali <- if (vali) "true" else "false"
    } else {
      vali <- siQuote(vali)
    }
    line[i] <- glue::glue("{keys[[i]]}: {vali}")
  }
  if (create) {
    appends <- what == -9L
    if (any(appends)) {
      start <- length(l)
      end <- start + length(what[appends])
      what[appends] <- seq(from = start + 1L, to = end)
    }
  } else {
    toss <- what == 0
    if (any(toss)) {
      cli::cli_alert_danger("{?This/These} key{?s} do not exist: {.code {keys[toss]}}")
      cli::cli_alert_info("Use {.code create = TRUE} if you want to create new keys")
      stop("`set_config()`: Unknown keys", call. = FALSE)
    }
  }
  if (write) {
    cli::cli_alert_info("Writing to {.file {cfg}}")
    for (i in seq(line)) {
      cli::cli_alert("{l[what][i]} -> {line[i]}")
    }
    l[what] <- line
    writeLines(l, cfg)
  } else {
    the_call <- match.call()
    thm <- cli::cli_div(theme = sandpaper_cli_theme())
    on.exit(cli::cli_end(thm))
    for (i in seq(line)) {
      not_missing <- !is.na(l[what][i])
      if (not_missing) {
        cli::cli_text(c(cli::col_cyan("- "), cli::style_blurred(l[what][i])))
      }
      cli::cli_text(c(cli::col_yellow("+ "), line[i]))
    }
    show_write_hint(match.call())
  }
}


#' @export
#' @rdname set_dropdown
set_episodes <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "episodes")
  show_write_hint(match.call())
}

#' @export
#' @rdname set_dropdown
set_learners <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "learners")
  show_write_hint(match.call())
}

#' @export
#' @rdname set_dropdown
set_instructors <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "instructors")
  show_write_hint(match.call())
}

#' @export
#' @rdname set_dropdown
set_profiles <- function(path = ".", order = NULL, write = FALSE) {
  set_dropdown(path, order, write, "profiles")
  show_write_hint(match.call())
}

