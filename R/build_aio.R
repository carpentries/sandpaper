#' Build the All-in-one page
#'
#' @param pkg an object created by {pkgdown}, supplied by [build_site()].
#' @param quiet If `TRUE` then no messages will be shown when building.
#'
#' This function will build the all-in-one page for the lesson website. Because
#' the bottleneck is often the internal processes of {pkgdown}, we are first 
#' templating the AIO page as a blank page and then adding in the contents using
#' {xml2}.
#' @keywords internal
build_aio <- function(pkg, quiet) {
  path <- root_path(pkg$src_path)
  out_path <- pkg$dst_path
  this_lesson(path)
  aio <- provision_aio(pkg, quiet)
  if (aio$needs_episodes) {
    remove_fix_node(aio$learner)
    remove_fix_node(aio$instructor)
  }
  lesson_content <- ".//main/div[contains(@class, 'lesson-content')]"
  learn <- get_sections(aio$learner, pkg, aio = TRUE)
  learn_parent <- xml2::xml_find_first(aio$learner, lesson_content)
  instruct <- get_sections(aio$instructor, pkg, aio = TRUE)
  instruct_parent <- xml2::xml_find_first(aio$instructor, lesson_content)
  the_episodes <- .resources$get()[["episodes"]]
  the_slugs <- paste0("episode-", get_slug(the_episodes))
  old_names <- names(learn)
  
  for (episode in seq(the_episodes)) {
    this_episode <- the_episodes[episode]
    ename       <- the_slugs[episode]
    ep_learn    <- get_sections(this_episode, pkg)
    ep_instruct <- get_sections(this_episode, pkg, instructor = TRUE)
    if (ename %in% old_names) {
      update_section(learn[[ename]], ep_learn)
      update_section(instruct[[ename]], ep_instruct)
    } else {
      make_section(ename, ep_learn, learn_parent)
      make_section(ename, ep_instruct, instruct_parent)
    }
  }
  writeLines(as.character(aio$learner), fs::path(out_path, "aio.html"))
  writeLines(as.character(aio$instructor), fs::path(out_path, "instructor", "aio.html"))
}
get_sections <- function(episode, pkg, aio = FALSE, instructor = FALSE) {
  if (!inherits(episode, "xml_document")) {
    if (instructor) {
      path <- fs::path(pkg$dst_path, "instructor", as_html(episode))
    } else {
      path <- fs::path(pkg$dst_path, as_html(episode))
    }
    episode <- xml2::read_html(path)
  }
  XPath <- ".//main/div[contains(@class, 'lesson-content')]/{content}"
  content <- if (aio) "section" else "*"
  res <- xml2::xml_find_all(episode, glue::glue(XPath))
  if (aio) {
    names(res) <- xml2::xml_attr(res, "id")
  }
  res
}

provision_aio <- function(pkg, quiet) {
  page_globals <- setup_page_globals()
  aio <- fs::path(pkg$dst_path, "aio.html")
  iaio <- fs::path(pkg$dst_path, "instructor", "aio.html")
  needs_episodes <- TRUE || !fs::file_exists(iaio) # this only saves us ~100ms in reality
  if (needs_episodes) {
    html <- xml2::read_html("<section id='FIXME'></section>")

    this_dat <- list(
      this_page = "aio.html",
      body = html,
      pagetitle = "All in one view"
    )

    page_globals$instructor$update(this_dat)
    page_globals$learner$update(this_dat)
    page_globals$meta$update(this_dat)

    build_html(template = "extra", pkg = pkg, nodes = html,
      global_data = page_globals, path_md = "aio.html", quiet = quiet)
  }
  return(list(learner = xml2::read_html(aio), 
    instructor = xml2::read_html(iaio),
    needs_episodes = needs_episodes)
  )
}

remove_fix_node <- function(html) {
  fix_node <- xml2::xml_find_first(html, ".//section[@id='FIXME']")
  xml2::xml_remove(fix_node)
  return(html)
}

move_section <- function(html, section, sibling, where = "after") {
  XPath <- ".//section[@id='{id}']"
  section <- xml2::xml_find_first(html, glue::glue(XPath, id = section))
  sibling <- xml2::xml_find_first(html, glue::glue(XPath, id = sibling))
  xml2::xml_add_sibling(sibling, section, .where = where)
  xml2::xml_remove(section)
  html
}

section_contents <- function(section) {
  contents <- "./section | ./div"
  xml2::xml_find_all(section, contents)
}

update_section <- function(section, new) {
  to_clean <- section_contents(section)
  info     <- xml2::xml_find_first(section, "./hr")
  xml2::xml_remove(to_clean)
  for (node in rev(new)) {
    xml2::xml_add_sibling(info, node, .where = "after")
  }
  section
}

make_section <- function(name, contents, parent) {
  uri <- sub("episode-", "", name)
  title <- xml2::xml_text(contents[[1]])
  new_section <- "<section id='{name}'><p>Content from <a href='{uri}.html'>{title}</a></p><hr/></section>"
  section <- xml2::read_xml(glue::glue(new_section))
  for (element in contents[-1]) {
    xml2::xml_add_child(section, element)
  }
  xml2::xml_add_child(parent, section)
}


get_title <- function(doc) {
  xml2::xml_find_first(doc, ".//h1")
}


