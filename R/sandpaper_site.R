#' Site generator for sandpaper
#'
#' This is a custom site generator for compatibility with 
#' [rmarkdown::site_generator()]. For RStudio users, **placing this in 
#' the `index.md` yaml header will make the knit button work**:
#'
#' ```yaml
#' site: sandpaper::sandpaper_site
#' ```
#'
#' This will be automatically added to the `index.md` for all sandpaper sites
#' from version 0.0.0.9013, so maintainers should not need to worry about this.
#'
#' Thanks goes to Yihui Xie for coming up with the concept of modular site
#' generators and for JJ Alaire for allowing sub-directory structures for 
#' RMarkdown sites. 
#'
#' @export
#' @keywords internal
sandpaper_site <- function(input = ".", ...) {
  # Rendering function ---------------------------------------------------------
  #
  # At the moment, this is a thin wrapper around build_lesson, but it's a good
  # place to start thinking about the redesign for the backend. It's also a
  # good place to instruct people to render their own lessons.
  #
  # TODO: reduce the time needed to re-render a single episode.
  render = function(input_file = input, output_format = "all", envir = new.env(), quiet = FALSE, encoding = "UTF-8", ...) {
    input_file <- if (is.null(input_file)) "." else input_file
    sandpaper::build_lesson(input_file, quiet = quiet, preview = quiet)
  }
  name <- get_config(root_path(input))$title
  # Note: this needs to be a relative path so RStudio can understand where we
  #       are placing this. 
  # TODO: find a better method to work on this. 
  out_dir <- fs::path_rel(fs::path(path_site(input), "docs"), root_path(input))
  list(
    name       = name,
    output_dir = out_dir,
    render     = render,
    clean      = function() fs::dir_delete(path_site(input)),
    subdirs    = TRUE
  )
}
