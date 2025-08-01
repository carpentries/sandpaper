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
#' @param glosario a named list of glosario terms and definitions. Defaults to NULL.
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
render_html <- function(path_in, ..., quiet = FALSE, glosario = NULL) {
  htm <- tempfile(fileext = ".html")
  on.exit(unlink(htm), add = TRUE)
  links <- getOption("sandpaper.links")
  if (length(links) && fs::file_exists(links)) {
    # if we have links, we concatenate our input files
    tmpin <- tempfile(fileext = ".md")
    fs::file_copy(path_in, tmpin)
    # if the file is not writable by the user, then we need to make it writable
    # https://github.com/carpentries/sandpaper/issues/479
    fs::file_chmod(tmpin, "u+w")
    cat("\n", file = tmpin, append = TRUE)
    file.append(tmpin, links)
    path_in <- tmpin
    on.exit(unlink(tmpin), add = TRUE)
  }

  if (!is.null(glosario)) {
    # if we have a glossary, then we need to replace the glossary term placeholders
    # with whisker.replace
    path_in <- render_glosario_links(path_in, glosario = glosario, quiet = quiet)
  }

  args <- construct_pandoc_args(path_in, output = htm, to = "html", ...)
  sho <- !(quiet || identical(Sys.getenv("TESTTHAT"), "true"))
  # Ensure we use the _loaded version_ of pandoc in case folks are using
  # the {pandoc} package: https://github.com/carpentries/sandpaper/issues/465
  this_pandoc <- rmarkdown::find_pandoc()
  callr::r(function(d, v, ...) {
    rmarkdown::find_pandoc(dir = d, version = v)
    rmarkdown::pandoc_convert(...)
  },
    args = c(d = as.character(this_pandoc$dir),
      v = as.character(this_pandoc$version),
      args),
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
