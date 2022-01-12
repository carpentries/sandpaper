# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

`%nin%` <- Negate("%in%")

as_html <- function(i) fs::path_ext_set(fs::path_file(i), "html")

# Parse a markdown title to html
#
# Note that commonmark wraps the content in <p> tags, so the substring gets rid
# of those:
# <p>Title</p>\n
parse_title <- function(title) {
  title <- commonmark::markdown_html(title)
  substring(title, 4, nchar(title) - 5)
}
# comparison function to test if a within a range of 2 b numbers
`%w%` <- function(a, b) a >= b[[1]] && a <= b[[2]]

# return the surrounding pages for the navbar links
page_location <- function(i, abs_md, er) {
  if (!i %w% er) {
    return(c(back = "index.md", forward = "index.md", progress = ""))
  }
  back <- if (i > er[1]) abs_md[i - 1] else "index.md"
  fwd  <- if (i < er[2]) abs_md[i + 1] else "index.md"
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
    if (inherits(html, "character")) {
      nodes <- xml2::read_html(html)
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

fix_nodes <- function(nodes) {
  # find all the div items that are purely section level 2
  fix_headings(nodes)
  fix_codeblocks(nodes)

}

fix_headings <- function(nodes) {
  # find all the div items that are purely section level 2
  h2 <- xml2::xml_find_all(nodes, ".//div[not(parent::div)][@class='section level2']/h2")
  xml2::xml_set_attr(h2, "class", "section-heading")
  xml2::xml_add_sibling(h2, "hr", class = "half-width", .where = "after")
  sections <- xml2::xml_parent(h2)
  xml2::xml_set_name(sections, "section")
  xml2::xml_set_attr(sections, "class", NULL)
  invisible(nodes)
}

fix_codeblocks <- function(nodes) {
  code <- xml2::xml_find_all(nodes, ".//div[starts-with(@class, 'sourceCode')]")
  xml2::xml_set_attr(code, "class", "codewrapper sourceCode")
  pre <- xml2::xml_children(code)
  type <- rev(trimws(sub("sourceCode", "", xml2::xml_attr(pre, "class"))))
  add_code_heading(pre, toupper(type))
  outputs <- xml2::xml_find_all(nodes, ".//pre[@class='output']")
  if (length(outputs)) {
    xml2::xml_add_parent(outputs, "div", class = "codewrapper")
    add_code_heading(outputs, "OUTPUT")
  }
  return(nodes)
}

add_code_heading <- function(codes, labels = "OUTPUT") {
  xml2::xml_set_attr(codes, "tabindex", "0")
  heads <- xml2::xml_add_sibling(codes, "h3", labels, class = "code-label", 
    .where = "before")
  for (head in heads) {
    xml2::xml_add_child(head, "i", 
      "aria-hidden" = "true", "data-feather" = "chevron-left")
    xml2::xml_add_child(head, "i", 
      "aria-hidden" = "true", "data-feather" = "chevron-right")
  }
  invisible(codes)
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

copy_maybe <- function(path, new_path) {
  if (fs::file_exists(path)) {
    fs::file_copy(path, new_path, overwrite = TRUE)
  }
}

copy_lockfile <- function(sources, new_path) {
  lock <- fs::path_file(sources) == "renv.lock"
  this_lock <- sources[lock]
  this_lock <- this_lock[length(this_lock)]
  if (any(lock) && fs::file_exists(this_lock)) {
    fs::file_copy(this_lock, new_path, overwrite = TRUE)
  }
}

UTC_timestamp <- function(x) format(x, "%F %T %z", tz = "UTC")

# Functions for backwards compatibility for R < 3.5
isFALSE <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && !x
isTRUE  <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && x

create_lesson_readme <- function(name, path) {

  writeLines(glue::glue("# {name}
      
      This is the lesson repository for {name}
  "), con = fs::path(path, "README.md"))

}

create_site_readme <- function(path) {
  readme <- fs::path(path_site(path), "README.md")
  if (!fs::file_exists(readme)) {
    fs::file_create(readme)
  }
  writeLines(glue::glue("
  This directory contains rendered lesson materials. Please do not edit files
  here.  
  "), con = readme)
}

create_description <- function(path) {
  yaml <- yaml::read_yaml(path_config(path), eval.expr = FALSE)
  the_author <- paste(gert::git_signature_default(path), "[aut, cre]")
  the_author <- utils::as.person(the_author)
  desc <- desc::description$new("!new")
  desc$del(c("BugReports", "LazyData"))
  desc$set_authors(the_author)
  desc$set(
    Package     = "lesson",
    Title       = yaml$title,
    Description = "Lesson Template (not a real package).",
    License     = yaml$license,
    Encoding    = "UTF-8"
  )
  desc$write(fs::path(path_site(path), "DESCRIPTION"))
}

which_carpentry <- function(carpentry) {
  switch(carpentry,
    lc = "Library Carpentry",
    dc = "Data Carpentry",
    swc = "Software Carpentry",
    cp = "The Carpentries",
    incubator = "Carpentries Incubator",
    lab = "Carpentries Lab"
  )
}

which_icon_carpentry <- function(carpentry) {
  switch(carpentry,
    lc = "library",
    dc = "data",
    swc = "software",
    cp = "carpentries",
    incubator = "incubator",
    lab = "lab"
  )
}

varnish_vars <- function() {
  ver <- function(pak) glue::glue(" ({packageVersion(pak)})")
  list(
    sandpaper_version = ver("sandpaper"),
    pegboard_version  = ver("pegboard"),
    varnish_version   = ver("varnish")
  )
}


copy_assets <- function(src, dst) {
  # Do not take markdown files.
  if (fs::path_ext(src) == "md") return(invisible(NULL))

  # FIXME: modify this to allow for non-flat file structure
  dst <- fs::path(dst, fs::path_file(src))

  # Copy either directories or files.
  if (fs::is_dir(src) && fs::path_file(src) != ".git") {
    tryCatch(fs::dir_copy(src, dst, overwrite = TRUE), error = function (e) {
      rel <- fs::path_common(c(src, dst))
      pth <- fs::path_rel(src, rel)
      cli::cli_alert_warning("There was an issue copying {.file {pth}}:\n{e$message}")
    })
  } else if (fs::is_file(src) && fs::path_file(src) != ".git") {
    fs::file_copy(src, dst, overwrite = TRUE)
  } else if (fs::path_file(src) == ".git") {
    # skipping git
  } else {
    stop(paste(src, "does not exist"), call. = FALSE)
  }
  return(invisible(NULL))
}

get_figs <- function(path, slug) {
  fs::path_abs(
    fs::dir_ls(
      path = fs::path(path_built(path), "fig"),
      regexp = paste0(slug, "-rendered-"),
      fixed = TRUE
    )
  )
}

check_order <- function(order, what) {
  if (is.null(order)) {
    stop(paste(what, "must have an order"), call. = FALSE)
  }
}


#nocov start
# Make it easy to contribute to our gitignore template, but also avoid having
# to reload this thing every time we need it 
gitignore_items <- function() {
  ours <- readLines(template_gitignore(), encoding = "UTF-8")
  ours[!grepl("^([#].+?|)$", trimws(ours))]
}
#nocov end

