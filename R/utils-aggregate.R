# The functions in this file will run after all the content from the markdown
# files have been written to HTML. This will allow us to extract rendered
# content from these files to aggregate into summary files such as instructor
# notes, glossaries, and all-in-one page.

#' read all HTML files in a folder
#'
#' @param path the path to a folder with HTML files
#' @return a nested list of `html_documents` from [xml2::read_html()] with two
#'   top-level elements:
#'   - `$learner`: contains all of the html pages in the learner view
#'   - `$instructor`: all of the pages in the instructor view
#'   - `$paths`: the absolute paths for the pages
#'
#' @examples
#' tmpdir <- tempfile()
#' on.exit(fs::dir_delete(tmpdir))
#' fs::dir_create(tmpdir)
#' fs::dir_create(fs::path(tmpdir, "instructor"))
#' writeLines("<p>Instructor</p>", fs::path(tmpdir, "instructor", "index.html"))
#' writeLines("<p>Learner</p>", fs::path(tmpdir, "index.html"))
#' read_all_html(tmpdir)
#'
read_all_html <- function(path) {
  paths <- fs::path_abs(fs::dir_ls(path, glob = "*.html", recurse = TRUE))
  htmls <- lapply(paths, xml2::read_html)
  rel <- fs::path_rel(paths, start = path)
  splits <- sub("^[.]$", "learner", fs::path_dir(rel))
  htmls <- split(htmls, splits)
  slugs <- split(get_slug(rel), splits)

  names(htmls$learner) <- slugs$learner
  names(htmls$instructor) <- slugs$instructor
  c(htmls, list(paths = paths))
}

build_sitemap <- function(out, paths = NULL, quiet = TRUE) {
  if (!quiet) cli::cli_rule(cli::style_bold("Creating sitemap.xml"))
  url <- this_metadata$get()$url
  paths <- paths %||% fs::dir_ls(out, glob = "*.html", recurse = TRUE)
  urls <- paste0(url, fs::path_rel(paths, out))
  doc <- urls_to_sitemap(urls)
  sitemap <- fs::path(out, "sitemap.xml")
  xml2::write_xml(doc, file = sitemap)
  invisible()
}

urls_to_sitemap <- function(urls) {
  doc <- xml2::read_xml("<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'></urlset>")
  for (url in urls) {
    child <- xml2::read_xml(paste0("<url><loc>", url, "</loc></url>"))
    xml2::xml_add_child(doc, child)
  }
  doc
}
