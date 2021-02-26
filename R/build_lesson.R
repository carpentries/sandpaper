#' Build your lesson site
#'
#' In the spirit of {hugodown}, This function will build plain markdown files
#' as a minimal R package in the `site/` folder of your {sandpaper} lesson
#' repository tagged with the hash of your file to ensure that only files that
#' have changed are rebuilt. 
#' 
#' @param path the path to your repository (defaults to your current working
#' directory)
#' @param rebuild if `TRUE`, everything will be built from scratch as if there
#' was no cache. Defaults to `FALSE`, which will only build markdown files that
#' haven't been built before. 
#' @param quiet when `TRUE`, output is supressed
#' @param preview if `TRUE`, the rendered website is opened in a new window
#' @param override options to override (e.g. building to alternative paths). 
#'   This is used internally. 
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
#' build_lesson(tmp)
build_lesson <- function(path = ".", rebuild = FALSE, quiet = !interactive(), preview = TRUE, override = list()) {

  # step 0: build_lesson defaults to a local build
  slug <- if (fs::is_file(path)) get_slug(path) else NULL
  path <- set_source_path(path)
  on.exit(reset_build_paths())

  # step 1: build the markdown vignettes and site (if it doesn't exist)
  if (rebuild) {
    reset_site(path)
  } else {
    create_site(path)
  }

  built <- build_markdown(path = path, rebuild = rebuild, quiet = quiet)

  build_site(path = path, quiet = quiet, preview = preview, override = override, slug = slug)
  
} 

