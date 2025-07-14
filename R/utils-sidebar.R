# comparison function to test if a within a range of 2 b numbers
`%w%` <- function(a, b) a >= b[[1]] && a <= b[[2]]

# return the surrounding pages for the navbar links
page_location <- function(i, abs_md, er) {
  if (sum(er) == 0L) {
    idx <- fs::path(fs::path_dir(abs_md[[1]]), "index.md")
  } else {
    idx <- fs::path(fs::path_dir(abs_md[er[1]]), "index.md")
  }
  if (!i %w% er) {
    return(c(back = idx, forward = idx))
  }
  back <- if (i > er[1]) abs_md[i - 1] else idx
  fwd <- if (i < er[2]) abs_md[i + 1] else idx
  c(back = back, forward = fwd, index = i - er[1])
}


#' @param files a vector of markdown file names
#' @param type one of "learners" (default) or "instructors". If it is learners,
#'   the setup page will be excluded since it is included in the index. For
#'   "instructors", the instructor notes are included and the learner profiles
#'   are included.
#' @keywords internal
#' @aliases sidebar
#' @rdname create_sidebar
create_resources_dropdown <- function(files, type = "learners") {
  if (type == "learners") {
    files <- files[!grepl("setup[.]R?md$", fs::path_file(files))]
  }
  if (type == "instructors") {
    files <- files[!grepl("instructor-notes[.]R?md$", fs::path_file(files))]
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
      if (length(f) == 0) {
        return(f)
      }
      info <- get_navbar_info(f)
      make_links(info$href, parse_title(info$text))
    }, character(2))
    out[["extras"]] <- unname(res[1, , drop = TRUE])
    out[["resources"]] <- unname(res[2, , drop = TRUE])
  }
  return(out)
}

#' Create a single item that appears in the sidebar
#'
#' Varnish uses a sidebar for navigation across and within an episode. This
#' funciton will create a sidebar item for a single episode, providing a
#' dropdown menu of the sections within the episode _if it is labeled as the
#' current episode_.
#'
#' @param nodes html nodes of a webpage generated from [render_html()] or
#'   parsed from xml2 that have level 2 section headings with the class
#'   `section-heading`
#' @param link a character vector of length 1 that defines the HTML links to
#'   be used as the node for the sidebar item.
#' @param position either a number or "current", if "current", then the html is
#'   parsed for second level headings to list in the sidebar navigation.
#' @return a character vector with a div item to insert into the sidebar
#'   navigation
#' @keywords internal
#' @rdname create_sidebar_item
#' @examples
#' snd <- asNamespace("sandpaper")
#' html <- c(
#'   "<section id='one'><h2 class='section-heading'>Section 1</h2><p>section 1</p></section>",
#'   "<section id='two'><h2 class='section-heading'>Section 2</h2><p>section 2</p></section>"
#' )
#' nodes <- xml2::read_html(paste(html, collapse = "\n"))
#'
#' # The sidebar headings are extracted from the nodes
#' writeLines(snd$create_sidebar_headings(nodes))
#'
#' link <- "<a href='https://example.com/this-page.html'><em>This Page</em></a>"
#'
#' # the sidebar item will contain the headings if it is the current chapter
#' writeLines(snd$create_sidebar_item(nodes, link, position = "current"))
#'
#' # it will be an ordinary link otherwise
#' writeLines(snd$create_sidebar_item(nodes, link, position = 3))
create_sidebar_item <- function(nodes, link, position) {
  current <- position == "current"
  sidebar_data <- list(
    name = link,
    pos = position,
    headings = if (current) create_sidebar_headings(nodes) else NULL,
    current = current
  )
  whisker::whisker.render(readLines(template_sidebar_item()),
    data = sidebar_data
  )
}

#' @rdname create_sidebar_item
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
      child_html <- xml2::xml_contents(h2[[child]])
      no_anchor <- !xml2::xml_attr(child_html, "class") %in% "anchor"
      txt[child] <- paste(child_html[no_anchor], collapse = "")
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
#' @param disable_numbering a boolean indicating if the sidebar should not automatically
#'   number the chapters. Defaults to `FALSE`. If `TRUE`, developers should consider
#'   adding their own custom numbering to the chapter titles in the frontmatter.
#' @return a character vector of HTML divs that can be appended to display the
#'   sidebar.
#' @keywords internal
#' @seealso [create_sidebar_item()] for creation of individual sidebar items,
#'   [set_globals()] for where `create_sidebar()` is called and
#'   [build_html()] for where `update_sidebar()` is called.
#' @rdname create_sidebar
create_sidebar <- function(
    chapters,
    name = "",
    html = "<a href='https://carpentries.org'/>",
    disable_numbering = FALSE) {
  res <- character(length(chapters))

  for (i in seq(chapters)) {
    position <- if (name == chapters[i]) "current" else i
    info <- get_navbar_info(chapters[i])

    numbering_prefix = paste0(i - 1, ". ")
    # if numbering is disabled, remove list numbering prefix
    if (disable_numbering) {
      numbering_prefix = ""
    }

    # We use zero index to count the index page
    # (which is removed later if automated numbering is enabled)
    page_link <- paste0(
      "<a href='", info$href, "'>",
      numbering_prefix,
      parse_title(info$pagetitle),
      "</a>"
    )
    res[i] <- create_sidebar_item(html, page_link, position)
  }
  res
}

#' @param sidebar an object of class "list-store" which has a `"sidebar"`
#'   element in the stored list. See [set_globals()].
#' @param nodes the HTML nodes of an HTML page
#' @param this_page the path to the current HTML page
#' @param title the current title
#' @param item the index of the sidebar item to update
#' @rdname create_sidebar
update_sidebar <- function(
    sidebar = NULL, nodes = NULL, this_page = NULL,
    title = NULL, item = NULL) {
  if (is.null(sidebar)) {
    return(sidebar)
  }
  this_sidebar <- sidebar$get()[["sidebar"]]
  # When there is no title defined, we extract it from the links.
  if (is.null(title)) {
    item <- grep(
      paste0("[<]a href=['\"]", this_page, "['\"]"),
      this_sidebar
    )
    # if we cannot find it from the links, then we do not need to edit the
    # sidebar.
    if (length(item) == 0) {
      sidebar$set("sidebar", paste(this_sidebar, collapse = "\n"))
      return(sidebar)
    }
    # extract the title from the node, making sure to preserve the HTML content
    side_nodes <- xml2::xml_find_first(
      xml2::read_xml(this_sidebar[item]),
      ".//a"
    )
    title <- paste(as.character(xml2::xml_contents(side_nodes)), collapse = "")
  }
  if (is.null(item)) {
    item <- grep(paste0("[<]a href=['\"]", this_page, "['\"]"), this_sidebar)
  }
  if (length(item) > 0) {
    this_sidebar[item] <- create_sidebar_item(nodes, title, "current")
  }
  sidebar$set("sidebar", paste(this_sidebar, collapse = "\n"))
}

#' Fix the refs for a vector of sidebar nodes
#'
#' @description update links from a list of HTML node
#'
#' @param item a text representation of HTML nodes that contain `<a>` elements.
#' @param path,scheme,server,query,fragment character vectors of elements to
#'   replace. This can be a single element vector, which will be recycled or
#'   a vector with the same length as `item`.
#' @return the text representation of HTML nodes with the `href` element
#'   modified.
#'
#' @details Repeat after me: parsing HTML with regular expressions is bad.
#'   This function uses [xml2::read_html()] to parse incoming HTML content to
#'   convert the HTML string into an XML document where we can extract all of
#'   the anchor links, parse them and replace their contents without regex. This
#'   is acheived via [xml2::url_parse()] separating the URL into pieces and
#'   updating those pieces for each node.
#'
#'   `fix_sidebar_href()` is useful because The sidebar nodes needs to be
#'   updated for the 404 page so that all links use the published URL.
#'   NOTE: this does not take into account `port` or `user`.
#'
#'   The auxilary functions `make_url()`, `append()` and `prepend()` are used to
#'   convert the output of [xml2::url_parse()] back to a URL.
#'
#' @rdname fix_sidebar_href
#' @keywords internal
#' @examples
#' my_links <- c(
#'   "<div id='one'><div id='one-one'><a href='index.html'>Index</a></div></div>",
#'   "<div id='two'><div id='two-two'><a href='two.html'><em>Two</em></a></div></div>",
#'   "<div id='three'><div id='three-three'><a href='three.html'>Three</a></div></div>",
#'   "<div id='four'><div id='four-four'><a href='four.html'>Four</a></div></div>",
#'   "<div id='five'><div id='five-five'><a href='five.html'>Five</a></div></div>"
#' )
#'
#' snd <- asNamespace("sandpaper")
#' # Prepend a server to the links
#' snd$fix_sidebar_href(my_links, scheme = "https", server = "example.com")
#' snd$fix_sidebar_href(my_links, server = "https://example.com")
#'
#'
#' # Add an anchor to the links
#' snd$fix_sidebar_href(my_links, scheme = "https", fragment = "anchor")
#'
#' # NOTE: this will _always_ return a character vector, even if the input is
#' # incorrect
#' snd$fix_sidebar_href(list(), server = "example.com")
fix_sidebar_href <- function(
    item, path = NULL, scheme = NULL,
    server = NULL, query = NULL, fragment = NULL) {
  # exit early if nothing exists
  has_zero_length <- length(item) == 0L
  is_not_string <- !is.character(item)
  is_empty_string <- is.character(item) && length(item) == 1L && item == ""
  is_not_correct <- has_zero_length || is_not_string || is_empty_string
  if (is_not_correct) {
    return("")
  }
  html <- xml2::read_html(paste(item, collapse = "\n"))
  link <- xml2::xml_find_all(html, ".//a")
  href <- xml2::xml_attr(link, "href")
  url <- xml2::url_parse(href)
  args <- list(
    path = path,
    scheme = scheme,
    server = server,
    query = query,
    fragment = fragment
  )
  args <- args[lengths(args) > 0]
  xml2::xml_set_attr(link, "href", make_url(modifyList(url, args)))
  return(as.character(xml2::xml_find_all(html, "/html/body/*")))
}

#' @param parsed a data frame produced via [xml2::url_parse]
#' @rdname fix_sidebar_href
make_url <- function(parsed) {
  urls <- parsed$path
  urls <- append(urls, "?", parsed$query)
  urls <- append(urls, "#", parsed$fragment)
  urls <- prepend(parsed$server, "/", urls)
  urls <- prepend(parsed$scheme, "://", urls, trim = FALSE)
  return(urls)
}

#' @param first a character vector
#' @param sep a character vector of length 1
#' @param last a character vector, same length as `first` or length 1
#' @param trim a logical indicating if the leading and trailing `sep` should
#'   be trimmed from `first` and `last`.
#' @rdname fix_sidebar_href
append <- function(first, sep = "#", last, trim = TRUE) {
  if (trim) {
    first <- sub(paste0("[", sep, "]$"), "", first)
    last <- sub(paste0("^[", sep, "]"), "", last)
  }
  return(ifelse(last == "", first, paste0(first, sep, last)))
}

prepend <- function(first, sep = "#", last, trim = TRUE) {
  if (trim) {
    first <- sub(paste0("[", sep, "]$"), "", first)
    last <- sub(paste0("^[", sep, "]"), "", last)
  }
  return(ifelse(first == "", last, paste0(first, sep, last)))
}

