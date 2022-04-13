#' Build the All-in-one page
#'
#' @param pkg an object created by {pkgdown}, supplied by [build_site()].
#' @param quiet If `TRUE` then no messages will be shown when building.
#'
#' This function will build the all-in-one page for the lesson website. Because
#' the bottleneck is often the internal processes of {pkgdown}, we are first 
#' templating the AIO page as a blank page and then adding in the contents using
#' {xml2}.
#' 
#'
#' @note
#' This function assumes that you have already built all the episodes of your
#' lesson. 
#'
#' @keywords internal
#' @seealso [provision_aio], [make_section], [get_sections]
#' @examples
#' if (FALSE) {
#'   # build_aio() assumes that your lesson has been built and takes in a 
#'   # pkgdown object, which can be created from the `site/` folder in your
#'   # lesson.
#'   lsn <- "/path/to/my/lesson"
#'   pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#'
#'   build_aio(pkg, quiet = FALSE)
#' }
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
      # NOTE: this is in prepartion for a more coherent caching mechanism that
      #       will speed up builds a bit in the future, but this works for now.
      update_section(learn[[ename]], ep_learn) #nocov
      update_section(instruct[[ename]], ep_instruct) #nocov
    } else {
      make_section(ename, ep_learn, learn_parent)
      make_section(ename, ep_instruct, instruct_parent)
    }
  }
  writeLines(as.character(aio$learner), fs::path(out_path, "aio.html"))
  writeLines(as.character(aio$instructor), fs::path(out_path, "instructor", "aio.html"))
}

#' Get sections from an episode's HTML page
#'
#' @param episode an object of class `xml_document`, a path to a markdown or
#'   html file of an episode.
#' @inheritParams build_aio
#' @param aio if `TRUE`, the sections of the AiO page are returned named with
#'   their IDs. Defaults to `FALSE`, which returns all contents within the main
#'   div.
#' @param instructor if `TRUE`, the instructor version of the episode is read,
#'   defaults to `FALSE`. This has no effect if the episode is an `xml_document`.
#'
#' @details
#' The contents of the lesson are contained in the following templating cascade:
#'
#' ```html
#' <body>
#'   <div class='container'>
#'     <div class='row'>
#'       <div class='[...] primary-content'>
#'         <main>
#'           <div class='[...] lesson-content'>
#'             CONTENT HERE
#' ```
#'
#' This function will extract the content from the episode without the templating.
#' 
#' @keywords internal
#' @examples
#' if (FALSE) {
#' lsn <- "/path/to/lesson"
#' pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#' 
#' # for AiO pages, this will return only sections:
#' get_sections("aio", pkg, aio = TRUE)
#'
#' # for episode pages, this will return everything that's not template
#' get_sections("01-introduction", pkg)
#'
#' }
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

#' Provision an AiO page
#' 
#' @details
#' There are two things to know about the AiO page:
#'
#'  1. All content inside the page is recycled directly from the episode content
#'  2. building a page via {pkgdown} is a relatively slow process due to
#'     cross-linking procedures and larger pages take longer to build.
#'
#'  Because we know that we can always retrieve 1 from the other pages, it makes
#'  more sense for us to build a template pkgdown page to fill in later because
#'  the linking and highlighting has already been performed.
#'
#'  This will provision the AiO pages destructively. In the future, when we have
#'  our caching mechanism for HTML pages and template content in place, we will
#'  avoid making destructive changes and read in the AiO file if it exists.
#'
#' @inheritParams build_aio
#' @return a list with three elements:
#'
#'  - *learner*: an `xml_document` containing the aio page from the learner view
#'  - *instructor*: the corresponding `xml_document` from the instructor view
#'  - *needs_episodes*: a logical flag if `TRUE`, indicates that the template
#'    needs to be filled with episode content. If `FALSE`, content exists and
#'    may need to be updated.
#'
#' @keywords internal
#' @seealso build_aio
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

#' Make a section and place it inside the All In One page
#'
#' When an episode needs to be added to the AiO, this will insert the XML nodes
#' from the episode contents in its own section inside the All In One page.
#'
#' @param name the name of the section, prefixed with `episode-`
#' @param contents the episode contents from [get_sections()]
#' @param parent the parent div of the AiO page. 
#' @return the section that was added to the parent
#'
#' @keywords internal
#' @seealso [build_aio()], [get_sections()]
#' @examples
#' if (FALSE) {
#' lsn <- "/path/to/lesson"
#' pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#' 
#' # read in the All in One page and extract its content
#' aio <- xml2::xml_parent(get_sections("aio", pkg))[[1]]
#' episode_content <- get_sections("01-introduction", pkg)
#' make_section("episode-01-introduction", 
#'   contents = episode_content, parent = aio)
#' }
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

# nocov start
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

get_title <- function(doc) {
  xml2::xml_find_first(doc, ".//h1")
}

# nocov end


