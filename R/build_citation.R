parse_cff <- function(cff_file) {
  cff_data <- read_cff(cff_file)
  if (is.null(cff_data)) {
    cli::cli_alert_warning("No valid citation information available.")
    return(NULL)
  }
  else {
    authors <- cff_data$authors %||% NULL
    affiliations <- ""
    if (!is.null(authors)) {
      auth_env <- parse_authors(authors)
      html_authors <- auth_env$html_authors
      pre_authors <- auth_env$pre_authors
      affiliations <- auth_env$affiliations
    }
    title <- cff_data$title %||% this_metadata$get()$pagetitle %||% "Untitled Lesson"
    abstract <- cff_data$abstract %||% ""
    version <- cff_data$version %||% "unversioned"
    date_released <- cff_data$`date-released` %||% this_metadata$get()$created %||% Sys.Date()
    identifiers <- cff_data$identifiers %||% list()

    identifiers <- sapply(identifiers, function(identifier) {
      if (is.list(identifiers)) {
        if (identifier$type == "doi") {
          identifier$value |> stringr::str_trim()
        }
      }
    })

    url <- cff_data$url %||% this_metadata$get()$url %||% NULL

    html_authors <- paste(html_authors, collapse = ", ")
    citation <- paste0(html_authors, " (", format(as.Date(date_released), "%Y"), "). <em>",
                       title, "</em>. Version [", version, "].")

    if (!is.null(url) && url != "") {
      citation <- paste(citation, "<br/><a href='", url, "'>", url, "</a>")
    }

    citation <- paste0(citation, affiliations)

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
        pc_html_authors <- pc_auth_env$html_authors
        pc_pre_authors <- pc_auth_env$pre_authors
        pc_affiliations <- pc_auth_env$affiliations
      }
      pc_title <- cf_pc$title %||% title
      pc_type <- cf_pc$type %||% NULL
      pc_date_released <- cf_pc$`date-released` %||% this_metadata$get()$created %||% Sys.Date()
      pc_version <- cf_pc$version %||% version
      pc_url <- cf_pc$url %||% this_metadata$get()$url %||% NULL

      if (pc_type == "article") {
        pc_journal <- cf_pc$journal %||% ""
        pc_doi <- cf_pc$doi %||% NULL

        citation <- paste0(pc_html_authors, " (", pc_date_released, "). <em>",
                           pc_title, "</em>. ", pc_journal)
        if (!is.null(cf_pc$volume)) {
          citation <- paste0(citation, ", ", cf_pc$volume)
        }
        if (!is.null(cf_pc$issue)) {
          citation <- paste0(citation, "(", cf_pc$issue, ")")
        }
        if (!is.null(cf_pc$pages)) {
          citation <- paste0(citation, ", ", cf_pc$pages)
        }
        if (!is.null(pc_doi)) {
          citation <- paste0(citation, ". https://doi.org/", pc_doi)
        }
      } else {
        # Fallback to preferred citation details if type is not article
        citation <- paste0(pc_html_authors, " (", pc_date_released, "). <em>",
                           pc_title, "</em>. Version [", pc_version, "].")
        if (!is.null(pc_doi)) {
          citation <- paste0(citation, " https://doi.org/", pc_doi)
        }
        if (!is.null(pc_url) && pc_url != "") {
          citation <- paste(citation, "<br/><a href='", pc_url, "'>", pc_url, "</a>")
        }
      }

      citation <- paste0(citation, pc_affiliations)
    }

    # unlist pre_authors to a single string
    pre_authors <- paste(pre_authors, collapse = ", ")
    pre_authors <- paste0(pre_authors, " (", format(as.Date(date_released), "%Y"), "). ",
                          title, ". Version [", version, "].")

    auth_env$formatted_pre_authors <- pre_authors
    auth_env$citation_html <- citation

    return(auth_env)
  }
}

# Function to read and parse CFF files
read_cff <- function(cff_file) {
  cff_data <- NULL
  if (fs::file_exists(cff_file)) {
    cff_file <- fs::path_abs(cff_file)

    if (requireNamespace("cffr", quietly = TRUE)) {
      # surround with tryCatch to handle potential errors
      tryCatch({
        valid <- cffr::cff_validate(cff_file)
        if (!valid) {
            cli::cli_alert_warning("CITATION.cff file is not valid according to CFF schema.")
            return(NULL)
        }

        cff_data <- cffr::cff_read_cff_citation(cff_file)
        if (!is.null(cff_data)) {
            # return link to the citation.html page
            return(cff_data)
        }
      }, error = function(e) {
        cli::cli_alert_warning("Error reading CITATION.cff file: {e$message}")
        return(NULL)
      })
    } else {
      cli::cli_alert_warning("{cffr} is required but not installed - cannot parse CITATION.cff file.")
      return(NULL)
    }
  }

  return(NULL)
}

generate_author_names <- function(authors, env, output_html = TRUE) {
  if (is.null(authors) || length(authors) == 0) {
    return("Unknown Author")
  }

  author_names <- sapply(authors, function(author) {
    if (is.list(author)) {
      given <- author[["given-names"]] %||% ""
      family <- author[["family-names"]] %||% ""
      affiliation <- author[["affiliation"]] %||% ""
      orcid <- author[["orcid"]] %||% ""

      if (output_html) {
        # produce HTML friendly author list with affiliations and orcid links
        name <- paste(given, family) |> stringr::str_trim()

        affil_num <- ""
        # add affiliation to unique list for use as links
        if (affiliation != "") {
            env$unique_affiliations <- union(env$unique_affiliations, c(affiliation))
            affil_num <- which(env$unique_affiliations == affiliation)[[1]] %||% ""
        }

        # add superscripted affiliation number and orcid link if available
        name <- paste0(name, "<span class='author-info'>")
        if (affil_num != "") {
            name <- paste0(name, " <a href='#aff", affil_num, "'><sup>", affil_num, "</sup></a> ")
        }
        if (orcid != "") {
            name <- paste0(name, " <a href='", orcid, "' target='_blank'><sup><img src='assets/images/orcid_icon.png' height='12' width='12'/></sup></a>")
        }
        name <- paste0(name, "</span>")
      }
      else {
        # abbreviate given names to initials for bibliography style reference
        given_names <- unlist(strsplit(given, " "))
        initials <- sapply(given_names, function(x) {
          paste0(substr(x, 1, 1))
        })
        name <- paste0(family, " ", paste0(initials, collapse = ""), ".") |> stringr::str_trim()
      }
    } else {
      as.character(author)
    }
  })

  return(author_names)
}

#' Create a citation page for a lesson from a CITATION.CFF file
#'
#' @export
#' @param path the path to the lesson. Defaults to current working directory
#' @param out the path to the citation page. When this is `NULL` (default)
#'   or `TRUE`, the output will be `site/built/citation.html`.
#' @return NULL
#'
#' @keywords internal
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

  html <- xml2::read_html(render_html(template_cff()))
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

  cff_meta <- this_metadata$get()$cff
  if (is.null(cff_meta) || cff_meta == "CITATION") {
    cli::cli_alert_warning("No CITATION.cff file found. Falling back to default behaviour.")
  }
  else {
    cff_env <- parse_cff(cff_meta)
    if (is.null(cff_env)) {
      return(NULL)
    }

    # add the pretty author list
    ct <- xml2::read_html(cff_env$citation_html)
    cit_p <- xml2::xml_find_first(html, ".//h2/following-sibling::p")
    xml2::xml_add_child(cit_p, ct)

    # set the metadata citation field to control footer "Cite" link href
    this_metadata$set("citation", ct)

    # add the copy-pasteable citation to the callout
    callout_citation <- cff_env$formatted_pre_authors
    cit_callout <- xml2::xml_find_first(html, ".//pre[@class='citation']/code")
    xml2::xml_set_text(cit_callout, callout_citation)

    this_dat <- list(
      this_page = "citation.html",
      body = html,
      pagetitle = tr_computed("CiteThisLesson")
    )
    page_globals$learner$update(this_dat)
    page_globals$metadata$update(this_dat)

    page_globals$instructor$update(list(
      this_page = "citation.html",
      body = use_instructor(html),
      pagetitle = tr_computed("CiteThisLesson")
    ))


    build_html(template = "citation", pkg = pkg, nodes = html,
               global_data = page_globals, path_md = "citation.html", quiet = quiet)
  }
}

# Function to process CFF author list
parse_authors <- function(authors) {
  if (is.null(authors) || length(authors) == 0) {
    return("Unknown Author")
  }

  env <- new.env()
  env$unique_affiliations <- c()

  html_author_names <- generate_author_names(authors, env, output_html = TRUE)
  pre_author_names <- generate_author_names(authors, env, output_html = FALSE)

  # generate a numbered list of affiliations
  affil_list <- ""
  if (length(env$unique_affiliations) > 0) {
    affil_list <- "<p style='font-size=0.8em'>Affiliations:<br/><ol class='affiliations'>"
    for (i in seq_along(env$unique_affiliations)) {
      affil_list <- paste0(affil_list, "<li id='aff", i, "'>", env$unique_affiliations[i], "</li>")
    }
    affil_list <- paste0(affil_list, "</ol></p>")
  }

  env$html_authors <- html_author_names
  env$pre_authors <- pre_author_names
  env$affiliations <- affil_list

  return(env)
}
