#' Build your lesson site
#'
#' This function orchestrates rendering generated lesson content and applying
#' the theme for the HTML site. 
#'
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
#' @export
#' @examples
#'
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE)
#' create_episode("first-script", path = tmp)
#' check_lesson(tmp)
#' if (rmarkdown::pandoc_available("2.11"))
#'   build_lesson(tmp)
build_lesson <- function(path = ".", rebuild = FALSE, quiet = !interactive(), preview = TRUE, override = list()) {

  # step 0: check pandoc installation; build_lesson defaults to a local build
  check_pandoc()
  slug <- if (fs::is_file(path)) get_slug(path) else NULL
  path <- set_source_path(path)
  this_lesson(path)
  initialise_metadata(path)

  on.exit(reset_build_paths())

  built <- build_markdown(path = path, rebuild = rebuild, quiet = quiet, slug = slug)

  build_site(path = path, quiet = quiet, preview = preview, override = override, slug = slug, built = built)
  
} 

