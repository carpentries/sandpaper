parse_cff <- function(cff_file, lesson) {
  cff_data <- read_cff(cff_file)
  if (is.null(cff_data)) {
    cli::cli_alert_warning("No citation information available. Returning link to CITATION.CFF file.")
    return(NULL)
  }

  authors <- cff_data$authors %||% NULL
  if (!is.null(authors)) {
    authors <- parse_authors(authors)
  }
  title <- cff_data$title %||% lesson$title %||% "Untitled Lesson"
  abstract <- cff_data$abstract %||% lesson$description %||% ""
  version <- cff_data$version %||% "unversioned"
  date_released <- cff_data$`date-released` %||% Sys.Date()
  identifiers <- cff_data$identifiers %||% list()

  identifiers <- sapply(identifiers, function(identifier) {
    if (is.list(identifiers)) {
      if (identifier$type == "doi") {
        identifier$value |> stringr::str_trim()
      }
    }
  })

  url <- cff_data$url %||% lesson$url %||% NULL

  citation <- paste0(authors, " (", format(as.Date(date_released), "%Y"), "). ",
                     title, ". Version ", version, ".")

  # citation <- paste("<ul>")
  doi <- cff_data$doi %||% NULL
  if (!is.null(doi)) {
    citation <- paste(" https://doi.org/", doi)
  }
#   else if (!is.null(identifiers) && length(identifiers) > 0) {
#     dois <- sapply(identifiers, function(identifier) {
#       paste("<li>https://doi.org/", identifier, "</li>")
#     })
#     citation <- paste(dois)
#   } else if (!is.null(url)) {
#     citation <- paste("<li>", url, "</li>")
#   }
#   citation <- paste("<ul>")

  cf_pc <- cff_data$`preferred-citation` %||% NULL
  if (!is.null(cf_pc)) {
    pc_authors <- cf_pc$authors %||% NULL
    if (is.null(pc_authors)) {
      pc_authors <- parse_authors(pc_authors)
    }
    pc_type <- cf_pc$type %||% NULL
    pc_version <- cf_pc$version %||% version
    if (pc_type == "article") {
      pc_journal <- cf_pc$journal %||% ""
      citation <- paste0(pc_authors, " (", cf_pc$year, "). ",
                         cf_pc$title, ". ", pc_journal)
      if (!is.null(cf_pc$volume)) {
        citation <- paste0(citation, ", ", cf_pc$volume)
      }
      if (!is.null(cf_pc$issue)) {
        citation <- paste0(citation, "(", cf_pc$issue, ")")
      }
      if (!is.null(cf_pc$pages)) {
        citation <- paste0(citation, ", ", cf_pc$pages)
      }
      if (!is.null(cf_pc$doi)) {
        citation <- paste0(citation, ". https://doi.org/", cf_pc$doi)
      }
    } else {
      # Fallback to preferred citation details if type is not article
      citation <- paste0(pc_authors, " (", cf_pc$year, "). ",
                         pc_title, ". Version [", pc_version, "].")
      if (!is.null(pc_doi)) {
        citation <- paste0(citation, " https://doi.org/", pc_doi)
      } else if (!is.null(url)) {
        citation <- paste0(citation, " ", url)
      }
    }
  }

  return(citation)
}

# Function to read and parse CFF files
read_cff <- function(cff_file) {
  cff_data <- NULL
  if (fs::file_exists(cff_file)) {
    cff_file <- fs::path_abs(cff_file)

    if (requireNamespace("cffr", quietly = TRUE)) {
      valid <- cffr::cff_validate(cff_file)
      if (!valid) {
        cli::cli_alert_warning("CITATION.CFF file is not valid according to CFF schema.")
        return(NULL)
      }

      cff_data <- cffr::cff_read_cff_citation(cff_file)
      if (!is.null(cff_data)) {
        # return link to the citation.html page
        return(cff_data)
      }
    }
  }

  return(NULL)
}

#' Create a citation page for a lesson from a CITATION.CFF file
#'
#' @export
#' @param path the path to the lesson. Defaults to current working directory
#' @param out the path to the citation page. When this is `NULL` (default)
#'   or `TRUE`, the output will be `site/built/citation.html`.
#' @return NULL
build_citation <- function(pkg, quiet = FALSE) {
  page_globals <- setup_page_globals()
  calls <- sys.calls()
  # When the page is in production (e.g. built with one of the `ci_` functions,
  # then we need to set the absolute paths to the site
  is_prod <- in_production(calls)
  if (is_prod) {
    url  <- page_globals$metadata$get()$url
    page_globals$instructor$set(c("site", "root"), url)
    page_globals$learner$set(c("site", "root"), url)
  }

  fof <- fs::path_package("sandpaper", "templates", "cff-template.txt")
  html <- xml2::read_html(render_html(fof))
  if (is_prod) {
    # make sure index links back to the original root
    lnk <- xml2::xml_find_first(html, ".//a[@href='index.html']")
    xml2::xml_set_attr(lnk, "href", url)
    # update navigation so that we have full URL
    nav <- page_globals$learner$get()[c("sidebar", "more", "resources")]
    for (item in names(nav)) {
      # replace the relative index with
      new <- fix_sidebar_href(nav[[item]], server = url)
      if (length(nav[[item]]) == 1L) {
        new <- paste(new, collapse = "")
      }
      page_globals$learner$set(item, new)
      page_globals$instructor$set(item, new)
    }
  }
  fix_nodes(html)

  ct <- parse_cff(this_metadata$get()$cff)
  this_metadata$set("citation", ct)

  this_dat <- list(
    this_page = "citation.html",
    body = html,
    pagetitle = tr_computed("CiteThisLesson")
  )
  page_globals$instructor$update(this_dat)
  page_globals$learner$update(this_dat)
  page_globals$metadata$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "citation.html", quiet = quiet)

  outpath <- fs::path(pkg$dst_path, "citation.html")
  ref_html <- xml2::read_html(outpath)
  ref_sect <- xml2::xml_find_first(ref_html, ".//section/h2[@id='cite-this-lesson']")
  cit_sect <- xml2::xml_add_child(ref_sect, "p", id="citation")
  xml2::xml_set_text(cit_sect, as.character(ct))
  writeLines(as.character(ref_html), outpath)
}

# Function to process CFF author list
parse_authors <- function(authors) {
  if (is.null(authors) || length(authors) == 0) {
    return("Unknown Author")
  }

  author_names <- sapply(authors, function(author) {
    if (is.list(author)) {
      given <- author[["given-names"]] %||% ""
      family <- author[["family-names"]] %||% ""
      paste(given, family) |> stringr::str_trim()
    } else {
      as.character(author)
    }
  })

  if (length(author_names) == 1) {
    return(author_names[1])
  } else if (length(author_names) == 2) {
    return(paste(author_names, collapse = " and "))
  } else {
    return(paste(paste(author_names[-length(author_names)], collapse = ", "),
                 "and", author_names[length(author_names)]))
  }
}