build_instructor_notes <- function(pkg, pages = NULL, built = NULL, quiet) {
  path <- root_path(pkg$src_path)
  this_lesson(path)
  outpath <- fs::path(pkg$dst_path, "instructor-notes.html")
  already_built <- template_check$valid() && 
    fs::file_exists(outpath) && 
    !is.null(built) && 
    !"instructor-notes" %in% get_slug(built)
  if (!already_built) {
    page_globals <- setup_page_globals()
    inote <- .resources$get()[["instructors"]]
    inote <- inote[get_slug(inote) == "instructor-notes"]
    html <- render_html(inote)
    if (html != '') {
      html  <- xml2::read_html(html)
      fix_nodes(html)
    }

    this_dat <- list(
      this_page = "instructor-notes.html",
      body = use_instructor(html),
      pagetitle = "Instructor Notes"
    )

    page_globals$instructor$update(this_dat)

    this_dat$body = use_learner(html)
    page_globals$learner$update(this_dat)

    page_globals$meta$update(this_dat)

    build_html(template = "extra", pkg = pkg, nodes = html,
      global_data = page_globals, path_md = "instructor-notes.html", quiet = quiet)
  }
  build_agg_page(pkg = pkg, 
    pages = pages, 
    title = this_dat$pagetitle, 
    slug = "instructor-notes", 
    aggregate = "/div[contains(@class, 'instructor-note')]//div[@class='accordion-body']", 
    append = "section[@id='aggregate-instructor-notes']",
    prefix = FALSE, 
    quiet = quiet)
}

make_instructornotes_section <- function(name, contents, parent) {
  title <- names(name)
  uri <- sub("^instructor-notes-", "", name)
  new_section <- "<section id='{name}'>
  <h2 class='section-heading'><a href='{uri}.html'>{title}</a></h2>
  <hr class='half-width'/>
  </section>"
  section <- xml2::read_xml(glue::glue(new_section))
  for (element in contents) {
    for (child in xml2::xml_children(element)) {
      xml2::xml_add_child(section, child)
    }
    xml2::xml_add_child(section, "hr")
  }
  xml2::xml_add_child(parent, section)
}
