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

      # Convert the list into a named list using the 'slug' as the name for each entry
      glos_dict <- setNames(glosario, sapply(glosario, function(x) x$slug))
      return(glos_dict)
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
    return(term)  # Return the term as-is if not found in the glossary
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

  # the processed file path for subsequent lesson processing as usual
  invisible(path_in)
}

#' @rdname build_glossary
build_glossary <- function(pkg, pages = NULL, quiet = FALSE) {
  build_glossary_page(
      pkg = pkg,
      pages = pages,
      # title = tr_computed("Glossary"),
      slug = "glossary",
      quiet = quiet,
  )
}

#' Build a page for aggregating glosario links found in lesson elements
#'
#' @inheritParams provision_agg_page
#' @param pages output from the function [read_all_html()]: a nested list of
#'   `xml_document` objects representing episodes in the lesson
#' @param aggregate a selector for the lesson content you want to aggregate.
#'   The default is "*", which will aggregate links from all content.
#'   To grab only links from sections, use "section".
#' @param append a selector for the section of the page where the aggregate data
#'   should be placed. This defaults to "self::node()", which indicates that the
#'   entire page should be appended.
#' @param quiet if `TRUE`, no messages will be emitted. If FALSE, pkgdown will
#'   report creation of the temporary file.
#' @return NULL, invisibly. This is called for its side-effect
#'
#' @details
#'
#' We programmatically search through lesson content to find links that point to
#' glosario terms. We then aggregate these links into a single page.
#'
#' To customise the page, we need a few things:
#'
#' 1. a title
#' 2. a slug
#' @note
#' This function assumes that you have already built all the episodes of your lesson.
#'
#' @keywords internal
#' @rdname build_glossary
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
build_glossary_page <- function(pkg, pages, title = "Glosario Links", slug = "reference", aggregate = "*", append = "self::node()", quiet = FALSE) {
  path <- get_source_path() %||% root_path(pkg$src_path)
  out_path <- pkg$dst_path
  this_lesson(path)

  lang <- this_metadata$get()[["lang"]]
  glosario = this_metadata$get()[["glosario"]]

  the_episodes <- .resources$get()[["episodes"]]
  the_slugs <- get_slug(the_episodes)

  # vector to hold all unique links from all episodes
  glinks <- character()

  for (episode in seq(the_episodes)) {
    ep_learn <- ep_instruct <- the_episodes[episode]
    ename <- the_slugs[episode]

    if (!is.null(pages)) {
      ep_learn <- pages$learner[[ename]]
      ep_instruct <- pages$instructor[[ename]]
    }
    ep_title <- as.character(xml2::xml_contents(get_content(ep_learn, ".//h1")))

    names(ename) <- paste(ep_title, collapse = "")

    ep_learn <- get_content(ep_learn, content = aggregate, pkg = pkg)
    ep_learn_glinks <- get_glossary_links(ep_learn)

    ep_instruct <- get_content(ep_instruct, content = aggregate, pkg = pkg, instructor = TRUE)
    ep_instruct_glinks <- get_glossary_links(ep_instruct)

    # get unique set of links from both learner and instructor
    ep_glinks <- unique(c(ep_learn_glinks, ep_instruct_glinks))

    # append unique episode glinks to global glinks
    glinks <- unique(c(ep_glinks, glinks))
  }

  glinks <- sort(glinks)

  agg <- provision_agg_page(pkg, title = title, slug = slug, new = TRUE)
  agg_sect <- xml2::xml_find_first(agg$learner, ".//section[@id='glossary']")

  agg_sect <- xml2::xml_add_child(agg_sect, "section", id="glosario")
  xml2::xml_add_child(agg_sect, "h2", "Glosario")
  agg_ul <- xml2::xml_add_child(agg_sect, "ul", id="glosario-list")

  # Iterate over glinks to create HTML elements
  for (link in glinks) {
    # remove everything before the last #
    link_term <- stringr::str_extract(link, "#(.*)")
    link_term <- stringr::str_replace(link_term, "#", "")

    # do not include glosario links that do not resolve to a term
    if (is.null(glosario[[link_term]])) {
      cli::cli_text("WARNING: Term not found in Glosario, not including: ", link_term)
      next
    }

    term <- glosario[[link_term]][[lang]]$term
    agg_li <- xml2::xml_add_child(agg_ul, "li")
    xml2::xml_add_child(agg_li, "a", term, href = link)

    if (is.null(glosario[[link_term]][[lang]]$def)) {
        def <- markdown::markdownToHTML(
            text = "_Definition not found in Glosario_",
            fragment.only = TRUE
        )
        def <- xml2::read_html(def)
    }
    else {
        def <- markdown::markdownToHTML(
            text = glosario[[link_term]][[lang]]$def,
            fragment.only = TRUE
        )

        def <- xml2::read_html(def)

        # find all hrefs in the def fragment
        anchors <- xml2::xml_find_all(def, ".//a")

        for (anchor in anchors) {
            href <- xml2::xml_attr(anchor, "href")
            # check if the href is a relative glosario link
            if (stringr::str_detect(href, "^#.*")) {
                # replace the href with the full URL
                url <- paste0(
                    "https://glosario.carpentries.org/",
                    this_metadata$get()[["lang"]],
                    "/",
                    href
                )
                xml2::xml_attr(anchor, "href") <- url
            }
        }
    }
    xml2::xml_add_child(agg_li, def)
  }

  outpath <- fs::path(pkg$dst_path, "reference.html")
  out <- fs::path_rel(outpath, pkg$dst_path)

  already_built <- template_check$valid() && fs::file_exists(outpath)

  if (already_built) {
    report <- "Rebuilding '{.file {out}}'"
    if (!quiet) cli::cli_text(report)

    # delete the existing reference.html file
    fs::file_delete(outpath)

    built_path <- fs::path(pkg$src_path, "built")

    # rebuild from scratch using build_episode_html
    build_episode_html(
      path_md = fs::path(built_path, "reference.md"),
      pkg = pkg,
      quiet = quiet,
      glosario = glosario
    )
  }
  else {
    report <- "Appending to '{.file {out}}'"
    if (!quiet) cli::cli_text(report)
  }

  ref_html <- xml2::read_html(outpath)
  ref_sect <- xml2::xml_find_first(ref_html, ".//main/div[contains(@class, 'lesson-content')]")
  xml2::xml_add_child(ref_sect, agg_sect)
  if (!quiet) cli::cli_text(report)
  writeLines(as.character(ref_html), outpath)
}

get_glossary_links <- function(episode) {
  lang <- this_metadata$get()[["lang"]]
  links <- xml2::xml_find_all(episode, ".//a")
  hrefs <- xml2::xml_attr(links, "href")
  glos_links <- links[stringr::str_detect(hrefs, "^https://glosario.carpentries.org/")]

  clean_links <- character()
  for (link in glos_links) {
    href <- xml2::xml_attr(link, "href")
    xml2::xml_attr(link, "href") <- stringr::str_replace_all(href, "en/", lang)
    clean_links <- c(clean_links, href)
  }
  invisible(clean_links)
}

get_title <- function(doc) {
  xml2::xml_find_first(doc, ".//h1")
}

# nocov end
