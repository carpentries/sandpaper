# comparison function to test if a within a range of 2 b numbers
`%w%` <- function(a, b) a >= b[[1]] && a <= b[[2]]

# return the surrounding pages for the navbar links
page_location <- function(i, abs_md, er) {
  idx <- fs::path(fs::path_dir(abs_md[er[1]]), "index.md")
  if (!i %w% er) {
    return(c(back = idx, forward = idx, progress = ""))
  }
  back <- if (i > er[1]) abs_md[i - 1] else idx
  fwd  <- if (i < er[2]) abs_md[i + 1] else idx
  pct  <- sprintf("%1.0f", (i - er[1])/(er[2] - er[1]) * 100)
  c(back = back, forward = fwd, progress = pct, index = i - er[1])
}


#' Create a single item that appears in the sidebar
#' 
#' Varnish uses a sidebar for navigation across and within an episode. This
#' funciton will create a sidebar item for a single episode, providing a 
#' dropdown menu of the sections within the episode if it is labeled as the 
#' current episode.
#'
#' @param nodes html generated from [render_html()] or parsed from xml2
#' @param name the name of the chapter to render
#' @param position either a number or "current", if "current", then the html is
#'   parsed for second level headings to list in the sidebar navigation.
#' @return a character vector with a div item to insert into the sidebar navigation
#' @keywords internal
create_sidebar_item <- function(nodes, name, position) {
  current <- position == "current"
  headings <- NULL
  if (current) {
    if (inherits(nodes, "character")) {
      nodes <- xml2::read_html(nodes)
    }
    # find all the div items that are purely section level 2
    h2 <- xml2::xml_find_all(nodes, ".//section/h2[@class='section-heading']")
    have_children <- xml2::xml_length(h2) > 0
    txt <- xml2::xml_text(h2)
    ids <- xml2::xml_attr(xml2::xml_parent(h2), "id")
    if (any(have_children)) {
      txt[have_children] <- as.character(xml2::xml_children(h2[have_children]))
    }
    if (length(ids) && length(txt)) {
      headings <- paste0("<li><a href='#", ids, "'>", txt, "</a></li>",
        collapse = "\n"
      )
    }
  }
  whisker::whisker.render(readLines(template_sidebar_item()), 
    data = list(name = name, pos = position, headings = headings, current = current))
}

#' Create the sidebar for varnish
#'
#' Varnish uses a sidebar for navigation across and within an episode. Each 
#' episode's sidebar is different because there needs to be a clear indicator
#' which episode is the current one within the sidebar. 
#'
#' This function creates that sidebar.
#'
#' @param chapters a character vector of paths to markdown chapters
#' @param name the name of the current chapter
#' @param html the html of the current chapter. defaults to a link that will
#'   produce a sidebar with no links to headings.
#' @keywords internal
create_sidebar <- function(chapters, name = "", html = "<a href='https://carpentries.org'/>") {
  res <- character(length(chapters))
  for (i in seq(chapters)) {
    position <- if (name == chapters[i]) "current" else i
    info <- get_navbar_info(chapters[i])
    page_link <- paste0("<a href='", info$href, "'>", info$pagetitle, "</a>")
    res[i] <- create_sidebar_item(html, page_link, position)
  }
  res
}
