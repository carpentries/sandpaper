#' Build your lesson site
#'
#' This function orchestrates rendering generated lesson content and applying
#' the theme for the HTML site.
#'
#' @param path the path to your repository (defaults to your current working
#' directory)
#' @param rebuild if `TRUE`, everything will be built from scratch as if there
#' was no cache. Defaults to `FALSE`, which will only build markdown files that
#' haven't been built before.
#' @param quiet when `TRUE`, output is supressed
#' @param preview if `TRUE`, the rendered website is opened in a new window
#' @param override options to override (e.g. building to alternative paths).
#'   This is used internally and will likely be changed.
#'
#' @return `TRUE` if it was successful, a character vector of issues if it was
#'   unsuccessful.
#'
#' @details
#'
#' ## Structure of a Workbench Lesson
#'
#' A Carpentries Workbench lesson is comprised of a set of markdown files and
#' folders:
#'
#' ```
#' +-- config.yaml
#' +-- index.md
#' +-- episodes
#' |   +-- data
#' |   +-- fig
#' |   +-- files
#' |   \-- introduction.Rmd
#' +-- instructors
#' |   \-- instructor-notes.md
#' +-- learners
#' |   \-- setup.md
#' +-- profiles
#' |   \-- learner-profiles.md
#' +-- links.md
#' +-- site
#'     \-- [...]
#' +-- renv
#' |   \-- [...]
#' +-- CODE_OF_CONDUCT.md
#' +-- CONTRIBUTING.md
#' +-- LICENSE.md
#' \-- README.md
#' ```
#'
#'
#' @export
#' @seealso [serve()]: an interactive way to build and edit lesson content.
#' @examplesIf sandpaper:::example_can_run()
#'
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE, rmd = FALSE)
#' create_episode("first-script", path = tmp, open = FALSE)
#' check_lesson(tmp)
#' build_lesson(tmp)
build_lesson <- function(path = ".", rebuild = FALSE, quiet = !interactive(), preview = TRUE, override = list()) {

  # Pre-flight compillation ----------------------------------------------------
  #
  # In this part, we need to do a couple of things:
  # 1. check that pandoc is present and fail early if it is not
  check_pandoc()
  # 2. check if we are only building one file and get its slug to pass to the
  #    markdown and site functions.
  slugpath <- get_build_slug(path, quiet = quiet)
  slug <- slugpath$slug
  # 3. set the source path global variable so that it can be used throughout the
  #    build process without explicitly needing to pass a variable from function
  #    to function, resetting the build path when the function exits (gracefully
  #    or ungracefully)
  path <- slugpath$path
  on.exit({
    reset_build_paths()
  })
  # 4. validate the lesson and set the global values for the lesson.
  #    This includes the following objects:
  #
  #    - .store..............the lesson as a pegboard::Lesson object
  #    - .resources..........a list of markdown resources for the lesson
  #    - this_metadata.......metadata with template for including in the pages
  #    - learner_globals.....variables for the learner version of the pages
  #    - instructor_globals..variables for the instructor version of the pages
  validate_lesson(path, quiet = quiet)

  # Building the markdown ------------------------------------------------------
  #
  # Once we know we have all of the lesson components, we can build the markdown
  # sources and store them in `site/built`. Only the markdown sources that have
  # changed in content will be rebuilt with `{knitr}`.
  built <- build_markdown(path = path, rebuild = rebuild, quiet = quiet, slug = slug)

  # Building the HTML ----------------------------------------------------------
  #
  # This step uses the contents of `site/built` to build the website in
  # `site/docs` with {whisker} and `{pkgdown}`
  build_site(path = path, quiet = quiet, preview = preview, override = override, slug = slug, built = built)

}

# Determine the build slug for lessons with child documents.
#
# The slug is the name of the file without the path or extension for the
# purposes of building a single file during the `serve()` and `knit` function
# operations.
#
# For child files, we need to take into account _where_ the child files exist.
#
# This function loops through the four possibilities of paths that can be passed
# to `build_lesson()`
#
# 1. a path to a lesson
# 2. the path to an existing source file
# 3. the path to a new source file
# 4. the path to a child file
#
# This function returns a list with the slug and the cleaned path to the lesson.
get_build_slug <- function(path, quiet = TRUE) {
  original_path <- path
  not_file <- !fs::is_file(path)
  # set the source path and return it
  path <- set_source_path(path)

  # CASE 1: path is a directory ---------------------------------------------
  # The base case: if we are building a directory, we don't need a slug and
  # we return early
  if (not_file) {
    return(list(slug = NULL, path = path))
  }

  # CASE 2: path is a source file -------------------------------------------
  # get the resource list and make it one big vector (use the stored resource
  # list to reduce lookup time)
  sources <- .resources$get() %||% get_resource_list(path)
  no_extra <- names(sources) %nin% c("files", "fig", "data")
  sources <- unlist(sources[no_extra], use.names = FALSE)
  # if we find the file in the sources, we can return the original path
  if (all(fs::path_file(original_path) %in% fs::path_file(sources))) {
    return(list(slug = get_slug(original_path), path = path))
  }

  # CASE 3: this is a new source file ---------------------------------------
  # load the lesson object and find the children
  lsn <- this_lesson(path)
  children <- names(lsn$children)
  if (length(children) == 0L) {
    # no children anywhere so we return the slug of that file
    return(list(slug = get_slug(original_path), path = path))
  }

  # CASE 4: we have a child file (maybe) ------------------------------------
  this_file <- fs::path_abs(original_path, start = path)
  if (this_file %in% children) {
    # the child exists and we rejoice!
    if (!quiet) cli::cli_alert_info("Found child document: {.path {this_file}}")
    parent <- lsn$children[[this_file]]$build_parents
    if (!quiet) cli::cli_alert("Building parent{?s}: {.path {parent}}")
  } else {
    # it's a new file that we missed.
    parent <- original_path
  }
  # if there are MULTIPLE parents, then just rebuild the whole thing
  # (slug = NULL) otherwise return the slug
  parent <- if (length(parent) > 1L) NULL else get_slug(parent)
  return(list(slug = parent, path = path))
}
