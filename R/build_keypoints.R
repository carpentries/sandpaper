build_keypoints <- function(pkg, quiet, sidebar = NULL) {
  page_globals <- setup_page_globals()
  path <- root_path(pkg$src_path)
  lesson <- this_lesson(path)
  keys <- vapply(lesson$episodes, function(i) {
    title <- i$get_yaml()$title
    keys  <- i$keypoints
    kp <- "No keypoints"
    if (length(keys) > 1) {
      kp <- paste("-", i$keypoints, collapse = "\n")
    }
    md <- paste0("## [", title, "](", as_html(i$name) ,")\n\n", kp, "\n\n")
    return(md)
  }, character(1))

  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  writeLines(keys, tmp)

  html <- xml2::read_html(render_html(tmp))
  fix_nodes(html)

  this_dat <- list(
    this_page = "keypoints.html",
    body = use_learner(html),
    pagetitle = "Keypoints"
  )
  page_globals$instructor$update(this_dat)
  page_globals$learner$update(this_dat)

  page_globals$meta$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "keypoints.html", quiet = quiet)
}
