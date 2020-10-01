#' Render html from a markdown file
#'
#' This uses [rmarkdown::pandoc_convert()] to render HTML from a markdown file.
#' We've specified pandoc extensions that align with the features desired in the
#' Carpentries such as `markdown_in_html_blocks`, `tex_math_dollars`, and 
#' `native_divs`.
#'
#' @param path_in path to a markdown file
#' @param quiet if `TRUE`, no output is produced. Default is `FALSE`, which 
#'   reports the markdown build via pandoc
#'
#' @return a character containing the rendred HTML file
#'
#' @keywords internal
#' @examples
#'
#' tmp <- tempfile()
#' ex <- c("# Markdown", 
#'   "", 
#'   "::: challenge", 
#'   "", 
#'   "How do you write markdown divs?",
#'   "", 
#'   ":::"
#' )
#' writeLines(ex, tmp)
#' cat(sandpaper:::render_html(tmp))
render_html <- function(path_in, quiet = FALSE) {
  htm <- tempfile(fileext = ".html")
  on.exit(unlink(htm), add = TRUE)
  exts <- paste(
    "smart",
    "auto_identifiers",
    "tex_math_dollars",
    "tex_math_single_backslash",
    "markdown_in_html_blocks",
    "yaml_metadata_block",
    "header_attributes",
    "native_divs",
    sep = "+"
  )
  from <- paste0("markdown", "-hard_line_breaks", "+", exts)
  args <- list(
    input = path_in, 
    output = htm, 
    from = from,
    to = "html", options = c(
      "--indented-code-classes=sh", "--section-divs", "--mathjax"
    ),
    verbose = FALSE
  )
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args, show = !quiet)
  paste(readLines(htm), collapse = "\n")
}
