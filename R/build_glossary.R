read_glosario_yaml <- function(glosario) {
  if (is.null(glosario) || glosario == FALSE) {
    return(NULL)
  }
  else {
    # Load the glossary YAML file from the GitHub repository
    glosario_url <- "https://raw.githubusercontent.com/carpentries/glosario/main/glossary.yml"
    glosario_response <- httr::GET(glosario_url)

    if (httr::status_code(glosario_response) == 200) {
      glosario <- yaml::yaml.load(httr::content(glosario_response, as = "text"))
      return(glosario)
    } else {
      return(NULL)
    }
  }
}

# Function to generate the link if the term exists in the glossary
create_glosario_link <- function(term, slugs) {
  if (term %in% slugs) {
    url <- paste0("https://glosario.carpentries.org/", this_metadata$get()[["lang"]], "/#", term)
    return(paste0("[^", term, "^](", url, ")"))
  } else {
    return(term)  # Return the term as is if not found in the glossary
  }
}

render_glosario_links <- function(path_in, glosario = NULL, quiet = FALSE) {
  if (!is.null(glosario)) {
    content <- readLines(path_in)

    slugs <- lapply(glosario, function(x) x$slug)
    glos_pattern <- "\\{\\{\\s*glosario\\.(\\w+)\\s*\\}\\}"

    # replace {{ glosario.term }} placeholders with glossary link URLs
    glosarioed_content <- stringr::str_replace_all(
        content,
        pattern = glos_pattern,
        replacement = function(match) {
          term <- stringr::str_match(match, glos_pattern)[[2]]
          create_glosario_link(term, slugs)
        }
      )

    # overwrite the file with the new content
    writeLines(glosarioed_content, path_in)
  }
  invisible(path_in)
}

#' @rdname build_glossary
build_glossary <- function(pkg, pages = NULL, quiet = FALSE) {
  build_glossary_page(
      pkg = pkg,
      pages = pages,
      # title = tr_computed("Glossary"),
      slug = "glossary",
      prefix = TRUE,
      quiet = quiet,
  )
}

#' Build a page for aggregating glosario elements
#'
#' @inheritParams provision_agg_page
#' @param pages output from the function [read_all_html()]: a nested list of
#'   `xml_document` objects representing episodes in the lesson
#' @param aggregate a selector for the lesson content you want to aggregate.
#'   The default is "section", which will aggregate all sections, but nothing
#'   outside of the sections. To grab everything in the page, use "*"
#' @param append a selector for the section of the page where the aggregate data
#'   should be placed. This defaults to "self::node()", which indicates that the
#'   entire page should be appended.
#' @param prefix flag to add a prefix for the aggregated sections. Defaults to
#'   `FALSE`.
#' @param quiet if `TRUE`, no messages will be emitted. If FALSE, pkgdown will
#'   report creation of the temporary file.
#' @return NULL, invisibly. This is called for its side-effect
#'
#' @details
#'
#' Building an aggregate page is very much akin to copy/paste---you take the
#' same elements across several pages and paste them into one large page. We can
#' do this programmatically by using XPath to extract nodes from pages and add
#' them into the document.
#'
#' To customise the page, we need a few things:
#'
#' 1. a title
#' 2. a slug
#' 3. a method to prepare and insert the extracted content (e.g. [make_aio_section()])
#' @note
#' This function assumes that you have already built all the episodes of your
#' lesson.
#'
#' @keywords internal
#' @rdname build_agg
#' @examples
#' if (FALSE) {
#'   # build_glossary_page() assumes that your lesson has been built and takes in a
#'   # pkgdown object, which can be created from the `site/` folder in your
#'   # lesson.
#'   lsn <- "/path/to/my/lesson"
#'   pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#'
#'   htmls <- read_all_html(pkg$dst_path)
#'   build_glossary_page(pkg, htmls, quiet = FALSE)
#'   build_keypoints(pkg, htmls, quiet = FALSE)
#' }
build_glossary_page <- function(pkg, pages, title = NULL, slug = NULL, append = "self::node()", prefix = FALSE, quiet = FALSE) {
  path <- get_source_path() %||% root_path(pkg$src_path)
  out_path <- pkg$dst_path
  this_lesson(path)

  new_content <- append == "self::node()" || append == "self::*"
  agg <- provision_agg_page(pkg, title = "Glosario Links", slug = slug, new = new_content)

  agg_sect <- xml2::xml_find_first(agg$learner, ".//section[@id='glossary']")
  agg_ul <- xml2::xml_add_child(agg_sect, "ul", id="glosario-list")

  the_episodes <- .resources$get()[["episodes"]]
  the_slugs <- get_slug(the_episodes)
  the_slugs <- if (prefix) paste0(slug, "-", the_slugs) else the_slugs

  # vector to hold all unique links from all episodes
  glinks <- character()

  for (episode in seq(the_episodes)) {
    ep_learn <- ep_instruct <- the_episodes[episode]
    ename <- the_slugs[episode]

    if (!is.null(pages)) {
      name <- if (prefix) sub(paste0("^", slug, "-"), "", ename) else ename
      ep_learn <- pages$learner[[name]]
      ep_instruct <- pages$instructor[[name]]
    }
    ep_title <- as.character(xml2::xml_contents(get_content(ep_learn, ".//h1")))

    names(ename) <- paste(ep_title, collapse = "")
    ep_learn <- get_glossary_content(ep_learn, content = "self::node()", pkg = pkg)
    ep_learn_glinks <- get_glossary_links(ep_learn)

    ep_instruct <- get_glossary_content(ep_instruct, content = "self::node()", pkg = pkg, instructor = TRUE)
    ep_instruct_glinks <- get_glossary_links(ep_instruct)

    # get unique set of links from both learner and instructor
    ep_glinks <- unique(c(ep_learn_glinks, ep_instruct_glinks))

    # append unique episode glinks to global glinks
    glinks <- unique(c(ep_glinks, glinks))
  }

  glinks <- sort(glinks)

  # Iterate over glinks to create HTML elements
  for (link in glinks) {
    # remove everything before the last #
    term <- stringr::str_extract(link, "#(.*)")
    term <- str_replace(term, "#", "")
    agg_li <- xml2::xml_add_child(agg_ul, "li")
    xml2::xml_add_child(agg_li, "a", term, href = link)
  }

  glos_out <- fs::path(out_path, as_html(slug))
  report <- "Writing '{.file {glos_out}}'"
  out <- fs::path_rel(glos_out, pkg$dst_path)
  if (!quiet) cli::cli_text(report)
  writeLines(as.character(agg$learner), glos_out)
}

get_glossary_links <- function(episode) {
  lang <- this_metadata$get()[["lang"]]
  links <- xml2::xml_find_all(episode, ".//a")
  links <- links[xml2::xml_attr(links, "href") %>%
    stringr::str_detect("^https://glosario.carpentries.org/")]

  clean_links <- character()
  for (link in links) {
    href <- xml2::xml_attr(link, "href")
    xml2::xml_attr(link, "href") <- stringr::str_replace_all(href, "en/", lang)
    clean_links <- c(clean_links, href)
  }
  invisible(clean_links)
}

#' Get content to process into the glossary
#'
#' @param episode an object of class `xml_document`, a path to a markdown or
#'   html file of an episode.
#' @inheritParams build_aio
#' @param content an XPath fragment. defaults to "*"
#' @param label if `TRUE`, elements will be named by their ids. This is best
#'   used when content = "section".
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
#'   lsn <- "/path/to/lesson"
#'   pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#'
#'   # for AiO pages, this will return only the top-level sections:
#'   get_content("aio", content = "section", label = TRUE, pkg = pkg)
#'
#'   # for episode pages, this will return everything that's not template
#'   get_content("01-introduction", pkg = pkg)
#'
#'   # for things that are within lessons but we don't know their exact location,
#'   # we can prefix a `/` to double up the slash, which will produce
#' }
get_glossary_content <- function(
    episode, content = "*", label = FALSE, pkg = NULL,
    instructor = FALSE) {
  if (!inherits(episode, "xml_document")) {
    if (instructor) {
      path <- fs::path(pkg$dst_path, "instructor", as_html(episode))
    } else {
      path <- fs::path(pkg$dst_path, as_html(episode))
    }
    episode <- xml2::read_html(path)
  }
  XPath <- ".//main/div[contains(@class, 'lesson-content')]/{content}"
  res <- xml2::xml_find_all(episode, glue::glue(XPath))
  if (label) {
    names(res) <- xml2::xml_attr(res, "id")
  }
  res
}

get_title <- function(doc) {
  xml2::xml_find_first(doc, ".//h1")
}

# nocov end
