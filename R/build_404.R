build_404 <- function(pkg, quiet) {
  page_globals <- setup_page_globals()
  path  <- root_path(pkg$src_path)
  fof <- fs::path_package("sandpaper", "templates", "404-template.txt")
  html <- xml2::read_html(render_html(fof))
  fix_nodes(html)

  this_dat <- list(
    this_page = "404.html",
    body = use_instructor(html),
    pagetitle = "Page not found"
  )
  page_globals$instructor$update(this_dat)

  this_dat$body = use_learner(html)
  page_globals$learner$update(this_dat)

  page_globals$meta$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "404.html", quiet = quiet)
}
