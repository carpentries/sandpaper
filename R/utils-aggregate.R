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

provision_extra_template <- function(pkg, quiet = TRUE) {
  page_globals <- setup_page_globals()
  needs_episodes <- TRUE 
  html <- xml2::read_html("<section id='--FIXME'></section>")
  page <- "--FIXME.html"
  learner <- fs::path(pkg$dst_path, page)
  instructor <- fs::path(pkg$dst_path, "instructor", page)

  date <- Sys.Date()
  this_dat <- list(
    this_page = "--FIXME.html",
    body = html,
    pagetitle = "--FIXME TITLE",
    updated = date
  )

  page_globals$instructor$update(this_dat)
  page_globals$learner$update(this_dat)
  page_globals$metadata$update(c(this_dat, list(date = list(modified = date))))

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = page, quiet = quiet)
  on.exit({
    fs::file_delete(learner)
    fs::file_delete(instructor)
  })
  .html$set(c("template", "extra", "learner"), 
    as.character(xml2::read_html(learner))) 
  .html$set(c("template", "extra", "instructor"), 
    as.character(xml2::read_html(instructor))) 
}

provision_extra_page <- function(pkg, title = "Key Points", slug = "key-points", quiet) {
  if (is.null(.html$get()$template$extra)) {
    provision_extra_template(pkg)
  }

  learner <- .html$get()$template$extra$learner
  instructor <- .html$get()$template$extra$instructor
  learner <- gsub("--FIXME TITLE", title, learner)
  instructor <- gsub("--FIXME TITLE", title, instructor)
  learner <- gsub("--FIXME", slug, learner)
  instructor <- gsub("--FIXME", slug, instructor)

  return(list(learner = xml2::read_html(learner), 
    instructor = xml2::read_html(instructor),
    needs_episodes = TRUE)
  )
}

provision_fun <- function(slug) {
  get(paste0("provision_", sub("-", "", slug)), asNamespace("sandpaper"))
}
section_fun <- function(slug) {
  get(paste0("make_", sub("-", "", slug), "_section"), asNamespace("sandpaper"))
}

build_extra_page <- function(pkg, pages, title = NULL, slug = NULL, aggregate = "section", prefix = FALSE, quiet = FALSE) {
  path <- root_path(pkg$src_path)
  out_path <- pkg$dst_path
  this_lesson(path)

  provision <- provision_fun(slug)
  make_section <- section_fun(slug)

  agg <- provision(pkg, quiet)

  if (agg$needs_episodes) {
    remove_fix_node(agg$learner, slug)
    remove_fix_node(agg$instructor, slug)
  }

  learn <- get_content(agg$learner, content = "section", label = TRUE)
  learn_parent <- get_content(agg$learner, content = "self::*")

  instruct <- get_content(agg$instructor, content = "section", label = TRUE)
  instruct_parent <- get_content(agg$instructor, content = "self::*")

  the_episodes <- .resources$get()[["episodes"]]
  the_slugs <- get_slug(the_episodes)
  the_slugs <- if (prefix) paste0(slug, "-", the_slugs) else the_slugs
  old_names <- names(learn)
  
  for (episode in seq(the_episodes)) {
    ep_learn <- ep_instruct <- the_episodes[episode]
    ename    <- the_slugs[episode]
    if (!is.null(pages)) {
      name <- sub(paste0("^", slug, "-"), "", ename)
      ep_learn <- pages$learner[[name]]
      ep_instruct <- pages$instructor[[name]]
    }
    ep_title <- as.character(xml2::xml_contents(get_content(ep_learn, ".//h1")))
    names(ename) <- paste(ep_title, collapse = "")
    ep_learn    <- get_content(ep_learn, content = aggregate, pkg = pkg)
    ep_instruct <- get_content(ep_instruct, content = aggregate, pkg = pkg, instructor = TRUE)
    make_section(ename, ep_learn, learn_parent)
    make_section(ename, ep_instruct, instruct_parent)
  }
  learn_out <- fs::path(out_path, as_html(slug))
  instruct_out <- fs::path(out_path, as_html(slug, instructor = TRUE))
  writeLines(as.character(agg$learner), learn_out)
  writeLines(as.character(agg$instructor), instruct_out)
}

remove_fix_node <- function(html, id='FIXME') {
  fix_node <- xml2::xml_find_first(html, paste0(".//section[@id='", id, "']"))
  xml2::xml_remove(fix_node)
  return(html)
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
