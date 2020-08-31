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
  # step 1: build the markdown vignettes and site (if it doesn't exist)
  create_site(path)
  build_markdown(path = path, rebuild = rebuild, quiet = quiet)

  # step 2: build the package site
  pkg <- pkgdown::as_pkgdown(path_site(path))
  if (quiet) {
    f <- file()
    on.exit({
      sink()
      close(f)
    }, add = TRUE)
    sink(f)
  }
    pkgdown::init_site(pkg)
  episodes <- get_built_files(path)
  for (i in episodes) {
    build_episode(i, pkg, quiet = quiet)
  }
  fs::dir_walk(
    fs::path(pkg$src_path, "built", "assets"), 
    function(d) copy_assets(d, pkg$dst_path),
    all = TRUE
  )
  pkgdown::build_home(pkg, quiet = quiet, preview = FALSE)
  pkgdown::preview_site(pkg, "/", preview = preview)
  
} 

build_episode <- function(path_in, pkg, quiet = FALSE) {
  body <- html_from_md(path_in, quiet = quiet)
  yml  <- yaml::yaml.load(politely_get_yaml(path_in))
  pkgdown::render_page(pkg, 
    "title-body",
    data = list(
      pagetitle = yml$title, 
      body = body
    ), 
    path = fs::path_ext_set(fs::path_file(path_in), "html"),
    quiet = quiet
  )
} 

html_from_md <- function(path_in, quiet = FALSE) {
  tmp <- tempfile(fileext = ".html")
  on.exit(unlink(tmp), add = TRUE)
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
  rmarkdown::pandoc_convert(
    input = path_in, 
    output = tmp, 
    from = from,
    to = "html", options = c(
      "--indented-code-classes=sh", "--section-divs", "--mathjax"
    ),
    verbose = !quiet
  )
  paste(readLines(tmp), collapse = "\n")
}
