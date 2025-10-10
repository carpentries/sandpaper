parse_cff <- function(cff_file, lesson) {
  cff_data <- read_cff(cff_file)
  if (is.null(cff_data)) {
    cli::cli_alert_warning("No citation information available. Returning link to CITATION.CFF file.")
    return(NULL)
  }

  authors <- cff_data$authors %||% NULL
  affiliations <- ""
  if (!is.null(authors)) {
    auth_env <- parse_authors(authors)
    authors <- auth_env$authors
    affiliations <- auth_env$affiliations
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

  citation <- paste0(authors, " (", format(as.Date(date_released), "%Y"), "). <em>",
                     title, "</em>. Version ", version, ".")

  citation <- paste0(citation, affiliations)

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
    pc_affiliations <- ""
    if (!is.null(pc_authors)) {
      pc_auth_env <- parse_authors(pc_authors)
      pc_authors <- pc_auth_env$authors
      pc_affiliations <- pc_auth_env$affiliations
    }
    pc_type <- cf_pc$type %||% NULL
    pc_version <- cf_pc$version %||% version
    if (pc_type == "article") {
      pc_journal <- cf_pc$journal %||% ""
      citation <- paste0(pc_authors, " (", cf_pc$year, "). <em>",
                         cf_pc$title, "</em>. ", pc_journal)
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
      citation <- paste0(pc_authors, " (", cf_pc$year, "). <em>",
                         pc_title, "</em>. Version [", pc_version, "].")
      if (!is.null(pc_doi)) {
        citation <- paste0(citation, " https://doi.org/", pc_doi)
      } else if (!is.null(url)) {
        citation <- paste0(citation, " ", url)
      }
    }

    citation <- paste0(citation, pc_affiliations)
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

  ct <- xml2::read_html(parse_cff(this_metadata$get()$cff))
  this_metadata$set("citation", ct)

  this_dat <- list(
    this_page = "citation.html",
    body = html,
    pagetitle = tr_computed("CiteThisLesson")
  )
  page_globals$instructor$update(this_dat)
  page_globals$learner$update(this_dat)
  page_globals$metadata$update(this_dat)

  outpath <- fs::path(pkg$dst_path, "citation.html")
  inst_outpath <- fs::path(pkg$dst_path, "instructor/citation.html")
  out <- fs::path_rel(inst_outpath, pkg$dst_path)

  already_built <- template_check$valid() && fs::file_exists(inst_outpath)

  if (already_built) {
    report <- "Rebuilding '{.file {out}}'"
    if (!quiet) cli::cli_text(report)

    # delete the existing instructors/citation.html file
    fs::file_delete(inst_outpath)

    built_path <- fs::path(pkg$src_path, "built")
  }
  else {
    report <- "Appending to '{.file {out}}'"
    if (!quiet) cli::cli_text(report)
  }

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "citation.html", quiet = quiet)

  ref_html <- xml2::read_html(outpath)
  ref_sect <- xml2::xml_find_first(ref_html, ".//section/h2[@id='cite-this-lesson']/parent::section")
  cit_sect <- xml2::xml_add_child(ref_sect, "p", id="citation")
  xml2::xml_add_child(cit_sect, ct)
  writeLines(as.character(ref_html), outpath)

  ref_html <- xml2::read_html(inst_outpath)
  ref_sect <- xml2::xml_find_first(ref_html, ".//section/h2[@id='cite-this-lesson']/parent::section")
  cit_sect <- xml2::xml_add_child(ref_sect, "p", id="citation")
  xml2::xml_add_child(cit_sect, ct)
  writeLines(as.character(ref_html), inst_outpath)
}

# Function to process CFF author list
parse_authors <- function(authors) {
  if (is.null(authors) || length(authors) == 0) {
    return("Unknown Author")
  }

  env <- new.env()
  env$unique_affiliations <- c()

  author_names <- sapply(authors, function(author) {
    if (is.list(author)) {
      given <- author[["given-names"]] %||% ""
      family <- author[["family-names"]] %||% ""
      affiliation <- author[["affiliation"]] %||% ""
      orcid <- author[["orcid"]] %||% ""
      name <- paste(given, family) |> stringr::str_trim()

      affil_num <- ""
      # add affiliation to unique list for use as links
      if (affiliation != "") {
        env$unique_affiliations <- union(env$unique_affiliations, c(affiliation))
        affil_num <- which(env$unique_affiliations == affiliation)[[1]] %||% ""
      }

      # add superscript number for affiliation and orcid if available
      name <- paste0(name, "<span class='author-info'>")
      if (affil_num != "") {
        name <- paste0(name, " <a href='#aff", affil_num, "'><sup>", affil_num, "</sup></a> ")
      }
      if (orcid != "") {
        name <- paste0(name, " <a href='", orcid, "' target='_blank'><sup><img src='assets/images/orcid_icon.png' height='12' width='12'/></sup></a>")
      }
      name <- paste0(name, "</span>")
    } else {
      as.character(author)
    }
  })

  if (length(author_names) == 1) {
    output <- author_names[1]
  } else if (length(author_names) == 2) {
    output <- paste(author_names, collapse = " and ")
  } else {
    output <- paste(paste(author_names[-length(author_names)], collapse = ", "),
                 "and", author_names[length(author_names)])
  }

  # generate a numbered list of affiliations
  affil_list <- ""
  if (length(env$unique_affiliations) > 0) {
    affil_list <- "<p style='font-size=0.8em'>Affiliations:<br/><ol class='affiliations'>"
    for (i in seq_along(env$unique_affiliations)) {
      affil_list <- paste0(affil_list, "<li id='aff", i, "'>", env$unique_affiliations[i], "</li>")
    }
    affil_list <- paste0(affil_list, "</ol></p>")
  }

  env$authors <- output
  env$affiliations <- affil_list
  return(env)
}