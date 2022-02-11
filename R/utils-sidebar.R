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


#' Create dropdown menus for extra content
#'
#' @param files a vector of markdown file names
#' @param type one of "learners" (default) or "instructors". If it is learners,
#'   the setup page will be excluded since it is included in the index. For 
#'   "instructors", the instructor notes are included and the learner profiles
#'   are included.
#' @return a list with character vectors of HTML list elements. 
#' @keywords internal
create_resources_dropdown <- function(files, type = "learners") {
  if (type == "learners") {
    files <- files[!grepl("setup[.]R?md", fs::path_file(files))]
  }
  if (type == "instructors") {
    files <- files[!grepl("instructor-notes.md", fs::path_file(files))]
  }
  out <- list(extras = NULL, resources = NULL)
  # NOTE: this creates a vector of length two: the first one has links with the
  # class of dropdown-item that we use for the navigation bar; the other one
  # goes in the sidebar for mobile view.
  LI <- paste0("<li><a", c(" class='dropdown-item'", ""), " href='")
  NK <- "'>"
  FIN <- "</a></li>"
  make_links <- function(href, txt) {
    paste0(LI, href, NK, txt, FIN)
  }
  if (length(files) || type == "instructors") {
    res <- vapply(files, function(f) {
      if (length(f) == 0) return(f)
      info <- get_navbar_info(f)
      make_links(info$href, parse_title(info$text))
    }, character(2))
    prof <- make_links("profiles.html", "Learner Profiles")
    out[["extras"]] <- unname(c(prof[1], res[1, , drop = TRUE]))
    out[["resources"]] <- unname(c(prof[2], res[2, , drop = TRUE]))
  }
  return(out)
}

extras_menu <- function(path, type = "learners", header = TRUE) {
  files <- as.character(get_resource_list(path, trim = FALSE, type, warn = FALSE))
  if (type == "learners") {
    files <- files[!grepl("setup[.]R?md", fs::path_file(files))]
  }
  if (type == "instructors") {
    files <- files[!grepl("instructor-notes.md", fs::path_file(files))]
  }
  out <- NULL
  fragment <- if (header) " class='dropdown-item'" else ""
  LI <- paste0("<li><a", fragment, " href='")
  NK <- "'>"
  if (length(files) || type == "instructors") {
    res <- vapply(files, function(f) {
      if (length(f) == 0) return(f)
      info <- get_navbar_info(f)
      paste0(LI, info$href, NK, parse_title(info$text), "</a></li>")
    }, character(1))
    res <- c(res, paste0(LI, "profiles.html", NK, "Learner Profiles</a></li>"))
    out <- paste(res, collapse = "")
  }
  return(out)
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
  sidebar_data <- list(
    name = name,
    pos = position,
    headings = if (current) create_sidebar_headings(nodes) else NULL,
    current = current
  )
  whisker::whisker.render(readLines(template_sidebar_item()), 
    data = sidebar_data)
}

create_sidebar_headings <- function(nodes) {
  if (inherits(nodes, "character")) {
    nodes <- xml2::read_html(nodes)
  }
  # find all the div items that are purely section level 2
  h2 <- xml2::xml_find_all(nodes, ".//section/h2[@class='section-heading']")
  have_children <- xml2::xml_length(h2) > 0
  txt <- xml2::xml_text(h2)
  ids <- xml2::xml_attr(xml2::xml_parent(h2), "id")
  if (any(have_children)) {
    for (child in which(have_children)) {
      # Headings that have embedded HTML will need this
      child_html <- as.character(xml2::xml_contents(h2[[child]]))
      txt[child] <- paste(child_html, collapse = "")
    }
  }
  if (length(ids) && length(txt)) {
    paste0("<li><a href='#", ids, "'>", txt, "</a></li>",
      collapse = "\n"
    )
  } else {
    NULL
  }
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
