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
#' if (rmarkdown::pandoc_available("2.11")) {
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
#' }
render_html <- function(path_in, ..., quiet = FALSE) {
  htm <- tempfile(fileext = ".html")
  on.exit(unlink(htm), add = TRUE)
  links <- getOption("sandpaper.links")
  if (length(links) && fs::file_exists(links)) {
    # if we have links, we concatenate our input files 
    tmpin <- tempfile(fileext = ".md")
    fs::file_copy(path_in, tmpin)
    cat("\n", file = tmpin, append = TRUE)
    file.append(tmpin, links)
    path_in <- tmpin
    on.exit(unlink(tmpin), add = TRUE)
  }
  args <- construct_pandoc_args(path_in, output = htm, to = "html", ...)
  sho <- !(quiet || identical(Sys.getenv("TESTTHAT"), "true"))
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args, 
    show = !quiet, spinner = sho)
  paste(readLines(htm), collapse = "\n")
}

construct_pandoc_args <- function(path_in, output, to = "html", ...) {
  exts <- paste(
    "smart",
    "auto_identifiers",
    "autolink_bare_uris",
    "emoji",
    "footnotes",
    "header_attributes",
    "inline_notes",
    "link_attributes",
    "markdown_in_html_blocks",
    "native_divs",
    "tex_math_dollars",
    "tex_math_single_backslash",
    "yaml_metadata_block",
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
      "--preserve-tabs",
      "--indented-code-classes=sh", 
      "--section-divs", 
      "--mathjax",
      ...,
      "--lua-filter",
      lua_filter
    ),
    verbose = FALSE
  )
}
