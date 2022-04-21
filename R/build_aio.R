#' @rdname build_agg
build_aio <- function(pkg, pages = NULL, quiet = FALSE) {
  build_agg_page(pkg = pkg, pages = pages, title = "All in One View",
    slug = "aio", aggregate = "*", prefix = TRUE, quiet = quiet)
}


#' Make a section and place it inside the All In One page
#'
#' When an episode needs to be added to the AiO, this will insert the XML nodes
#' from the episode contents in its own section inside the All In One page.
#'
#' @param name the name of the section, prefixed with `episode-`
#' @param contents the episode contents from [get_content()]
#' @param parent the parent div of the AiO page. 
#' @return the section that was added to the parent
#'
#' @keywords internal
#' @seealso [build_aio()], [get_content()]
#' @examples
#' if (FALSE) {
#' lsn <- "/path/to/lesson"
#' pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#' 
#' # read in the All in One page and extract its content
#' aio <- get_content("aio", content = "self::*", pkg = pkg)
#' episode_content <- get_content("01-introduction", pkg = pkg)
#' make_aio_section("aio-01-introduction", 
#'   contents = episode_content, parent = aio)
#' }
make_aio_section <- function(name, contents, parent) {
  uri <- sub("aio-", "", name)
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


