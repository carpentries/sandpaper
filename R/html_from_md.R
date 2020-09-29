html_from_md <- function(path_in, quiet = FALSE) {
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
