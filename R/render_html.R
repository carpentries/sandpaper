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
#' @param ... extra options (e.g. lua filters) to be passed to pandoc
#'
#' @return a character containing the rendred HTML file
#'
#' @keywords internal
#' @examples
#'
#' # first example---markdown to HTML
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
#'
#' # adding a lua filter
#'
#' lua <- tempfile()
#' lu <- c("Str = function (elem)",
#' "  if elem.text == 'markdown' then",
#' "    return pandoc.Emph {pandoc.Str 'mowdrank'}",
#' "  end",
#' "end")
#' writeLines(lu, lua)
#' lf <- paste0("--lua-filter=", lua)
#' cat(sandpaper:::render_html(tmp, lf))
render_html <- function(path_in, ..., quiet = FALSE) {
  htm <- tempfile(fileext = ".html")
  on.exit(unlink(htm), add = TRUE)
  args <- construct_pandoc_args(path_in, output = htm, to = "html", ...)
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args, show = !quiet)
  paste(readLines(htm), collapse = "\n")
}

construct_pandoc_args <- function(path_in, output, to = "html", ...) {
  exts <- paste(
    "smart",
    "auto_identifiers",
    "autolink_bare_uris",
    "emoji",
    "footnotes",
    "inline_notes",
    "tex_math_dollars",
    "tex_math_single_backslash",
    "markdown_in_html_blocks",
    "yaml_metadata_block",
    "header_attributes",
    "native_divs",
    sep = "+"
  )
  from <- paste0("markdown", "-hard_line_breaks", "+", exts)
  lua_filter <- rmarkdown::pkg_file_lua("lesson.lua", "sandpaper")
  list(
    input   = path_in,
    output  = output,
    from    = from,
    to      = to,
    options = c(
      "--indented-code-classes=sh", 
      "--section-divs", 
      "--mathjax",
      "--lua-filter",
      lua_filter,
      ...
    ),
    verbose = FALSE
  )
}
