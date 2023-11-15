#' @rdname build_agg
#' @param built a vector of markdown documents that have recently been rebuilt
#'   (for future use)
build_instructor_notes <- function(pkg, pages = NULL, built = NULL, quiet) {
  path <- get_source_path() %||% root_path(pkg$src_path)
  lsn <- this_lesson(path)
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
    if (html != "") {
      html <- xml2::read_html(html)
      fix_nodes(html)
    } else {
      html <- xml2::read_html("<p></p>")
    }

    this_dat <- list(
      this_page = "instructor-notes.html",
      body = use_instructor(html),
      pagetitle = "Instructor Notes"
    )

    page_globals$instructor$update(this_dat)

    this_dat$body <- use_learner(html)
    page_globals$learner$update(this_dat)

    page_globals$metadata$update(this_dat)

    build_html(
      template = "extra", pkg = pkg, nodes = html,
      global_data = page_globals, path_md = "instructor-notes.html", quiet = TRUE
    )
  }
  # shortcut if we don't have any episodes
  is_overview <- lsn$overview && length(lsn$episodes) == 0
  if (is_overview) {
    return(invisible(NULL))
  }
  agg <- "/div[contains(@class, 'instructor-note')]//*[@class='accordion-body' or @class='accordion-header']"
  build_agg_page(
    pkg = pkg,
    pages = pages,
    title = this_dat$pagetitle,
    slug = "instructor-notes",
    aggregate = agg,
    append = "section[@id='aggregate-instructor-notes']",
    prefix = FALSE,
    quiet = quiet
  )
}

#' Make a section of aggregated instructor notes
#'
#' This will append instructor notes from the inline sections of the lesson to
#' the instructor-notes page, separated by section and `<hr>` elements.
#'
#' @param name the name of the section, (may or may not be prefixed with `images-`)
#' @param contents an `xml_nodeset` of figure elements from [get_content()]
#' @param parent the parent div of the images page
#' @return the section that was added to the parent
#' @note On the learner view, instructor notes will not be present
#'
#' @keywords internal
#' @seealso [build_instructor_notes()], [get_content()]
#' @examples
#' if (FALSE) {
#'   lsn <- "/path/to/lesson"
#'   pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#'
#'   # read in the All in One page and extract its content
#'   notes <- get_content("instructor-notes",
#'     content =
#'       "section[@id='aggregate-instructor-notes']", pkg = pkg, instructor = TRUE
#'   )
#'   agg <- "/div[contains(@class, 'instructor-note')]//div[@class='accordion-body']"
#'   note_content <- get_content("01-introduction", content = agg, pkg = pkg)
#'   make_instructornotes_section("01-introduction",
#'     contents = note_content,
#'     parent = notes
#'   )
#'
#'   # NOTE: if the object for "contents" ends with "_learn", no content will be
#'   # appended
#'   note_learn <- note_content
#'   make_instructornotes_section("01-introduction",
#'     contents = note_learn,
#'     parent = notes
#'   )
#' }
make_instructornotes_section <- function(name, contents, parent) {
  # Since we have hidden the instructor notes from the learner sections,
  # there is no point to iterate here, so we return early.
  the_call <- match.call()
  is_learner <- endsWith(as.character(the_call[["contents"]]), "learn")
  if (is_learner) {
    return(invisible(NULL))
  }
  title <- names(name)
  uri <- name
  new_section <- "<section id='{name}'>
  <h2 class='section-heading'><a href='{uri}.html'>{title}</a></h2>
  <hr class='half-width'/>
  </section>"
  section <- xml2::read_xml(glue::glue(new_section))
  for (element in contents) {
    is_heading <- xml2::xml_name(element) == "h3" &
      xml2::xml_attr(element, "class") == "accordion-header"
    if (is_heading) {
      # when we have an instructor note heading, we need to just add it and
      # then skip to the next section, which is the body.
      lnk <- make_instructor_note_linkback(element, name)
      xml2::xml_add_child(section, lnk)
      next
    }
    for (child in xml2::xml_children(element)) {
      xml2::xml_add_child(section, child)
    }
    xml2::xml_add_child(section, "hr")
    xml2::xml_add_child(section, "br")
  }
  xml2::xml_add_child(parent, section)
}

make_instructor_note_linkback <- function(node, name) {
  # we need to just make a completely new node out of the heading because
  # the accordion contains a bunch of junk.
  title <- trimws(xml2::xml_text(node))
  id <- xml2::xml_attr(node, "id")
  newid <- glue::glue("{name}-{id}")
  anchor <- glue::glue("<a class='anchor' aria-label='anchor' href='#{newid}'></a>")
  new <- "<h3><a href='{name}.html#{id}'>{title}</a>{anchor}</h3>"
  node <- xml2::read_xml(glue::glue(new))
  xml2::xml_set_attr(node, "id", newid)
  node
}

