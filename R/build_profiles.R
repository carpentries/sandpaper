build_profiles <- function(pkg, quiet) {
  page_globals <- setup_page_globals()
  path <- get_source_path() %||% root_path(pkg$src_path)
  profs <- get_profiles(path, trim = FALSE)
  html <- paste(vapply(profs, render_html, character(1)), collapse = "<hr>")
  if (html != '') {
    html  <- xml2::read_html(html)
    fix_nodes(html)
  } else {
    html <- xml2::read_html("<p>No learner profiles yet!</p>")
  }

  this_dat <- list(
    this_page = "profiles.html",
    body = use_instructor(html),
    pagetitle = "Learner Profiles"
  )
  page_globals$instructor$update(this_dat)

  this_dat$body = use_learner(html)
  page_globals$learner$update(this_dat)

  page_globals$metadata$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "profiles.html", quiet = quiet)
}

