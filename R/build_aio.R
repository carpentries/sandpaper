build_aio <- function(pkg, quiet) {
  page_globals <- setup_page_globals()
  path <- root_path(pkg$src_path)
  lesson <- this_lesson(path)
  htmls <- vapply(lesson$episodes, function(i) {
    title <- i$get_yaml()$title
    slug  <- get_slug(i$path)
    html  <- .html$get()[[slug]]
    glue::glue("<section id='episode-{slug}'>
      <p>Content from <a href='{slug}.html'>{slug}.html</a></p>
      <hr>
      {html}
    </section>")
  }, character(1))

  html <- xml2::read_html(paste(htmls, collapse = "\n"))
  fix_nodes(html)

  this_dat <- list(
    this_page = "aio.html",
    body = use_learner(html),
    pagetitle = "All in one view"
  )

  page_globals$instructor$update(this_dat)
  page_globals$instructor$set("body", use_instructor(html))

  page_globals$learner$update(this_dat)

  page_globals$meta$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "aio.html", quiet = quiet)
}
