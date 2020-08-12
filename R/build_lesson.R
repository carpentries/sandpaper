#' Build your lesson sitf 
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
#' 
#' @return `TRUE` if it was successful, a character vector of issues if it was
#'   unsuccessful.
#' 
#' @export
#' @examples
#'
#' tmp <- tempfile()
#' create_lesson(tmp)
#' create_episode("first-script", path = tmp)
#' check_lesson(tmp)
#' build_lesson(tmp)
build_lesson <- function(path = ".", rebuild = FALSE, quiet = FALSE, preview = TRUE) {
  # step 1: build the markdown vignettes
  build_markdown_vignettes(path = path, rebuild = rebuild, quiet = quiet)

  # step 2: build the package site
  pkgdown::init_site(path_site(path))
  pkgdown::build_home(path_site(path), preview = preview, quiet = quiet)
  pkgdown::build_articles(path_site(path), preview = preview, quiet = quiet)
} 
