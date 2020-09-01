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
  if (rebuild) {
    clear_site(path)
  } else {
    create_site(path)
  }
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
  n <- length(episodes)
  for (i in seq_along(episodes)) {
    build_episode(
      path_in = episodes[i], 
      page_back = if (i > 1) episodes[i - 1] else "index.md",
      page_forward = if (i < n) episodes[i + 1] else "index.md",
      pkg, 
      quiet = quiet
    )
  }
  fs::dir_walk(
    fs::path(pkg$src_path, "built", "assets"), 
    function(d) copy_assets(d, pkg$dst_path),
    all = TRUE
  )
  pkgdown::build_home(pkg, quiet = quiet, preview = FALSE)
  pkgdown::preview_site(pkg, "/", preview = preview)
  
} 

build_episode <- function(path_in, page_back = NULL, page_forward = NULL, pkg, quiet = FALSE) {
  body    <- html_from_md(path_in, quiet = quiet)
  yml     <- yaml::yaml.load(politely_get_yaml(path_in))
  as_html <- function(i) fs::path_ext_set(fs::path_file(i), "html")
  pkgdown::render_page(pkg, 
    "title-body",
    data = list(
      # NOTE: we can add anything we want from the YAML header in here to
      # pass on to the template.
      body         = body,
      pagetitle    = yml$title,
      teaching     = yml$teaching,
      exercises    = yml$exercises,
      page_back    = as_html(page_back),
      left         = if (page_back == "index.md") "up" else "left",
      page_forward = as_html(page_forward),
      right        = if (page_forward == "index.md") "up" else "right"
    ), 
    path = as_html(path_in),
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
