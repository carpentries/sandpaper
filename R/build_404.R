build_404 <- function(pkg, quiet) {
  page_globals <- setup_page_globals()
  calls <- sys.calls()
  is_prod <- in_production(calls)
  if (is_prod) {
    url  <- page_globals$metadata$get()$url
    page_globals$instructor$set(c("site", "root"), url)
    page_globals$learner$set(c("site", "root"), url)
  }
  path  <- root_path(pkg$src_path)

  fof <- fs::path_package("sandpaper", "templates", "404-template.txt")
  html <- xml2::read_html(render_html(fof))
  if (is_prod) {
    # make sure index links back to the original root
    lnk <- xml2::xml_find_first(html, ".//a[@href='index.html']")
    xml2::xml_set_attr(lnk, "href", url)
    # update navigation so that we have full URL
    nav <- page_globals$learner$get()[c("sidebar", "more", "resources")]
    for (item in names(nav)) {
      new <- gsub("href='", paste0("href='", url), nav[item])
      page_globals$learner$set(item, new)
      page_globals$instructor$set(item, new)
    }
  }
  fix_nodes(html)

  this_dat <- list(
    this_page = "404.html",
    body = html,
    pagetitle = "Page not found"
  )
  page_globals$instructor$update(this_dat)
  page_globals$learner$update(this_dat)
  page_globals$meta$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "404.html", quiet = quiet)
}
