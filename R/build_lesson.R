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
#' create_lesson(tmp, open = FALSE)
#' create_episode("first-script", path = tmp)
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
  slug <- if (fs::is_file(path)) get_slug(path) else NULL
  # 3. set the source path global variable so that it can be used throughout the
  #    build process without explicitly needing to pass a variable from function
  #    to function, resetting the build path when the function exits (gracefully
  #    or ungracefully)
  path <- set_source_path(path)
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
  # changed in content will be rebuilt with {knitr}.
  built <- build_markdown(path = path, rebuild = rebuild, quiet = quiet, slug = slug)

  # Building the HTML ----------------------------------------------------------
  #
  # This step uses the contents of `site/built` to build the website in
  # `site/docs` with {whisker} and {pkgdown}
  build_site(path = path, quiet = quiet, preview = preview, override = override, slug = slug, built = built)

}

