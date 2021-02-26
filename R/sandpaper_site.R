sandpaper_site <- function(input, ...) {
  render = function(input_file, output_format, envir, quiet, encoding, ...) {
    sandpaper::build_lesson(input_file, quiet = quiet)
  }
  list(
    name = "Tiddle",
    output_dir = "site/docs/",
    render = render,
    clean = reset_site
  )
}
