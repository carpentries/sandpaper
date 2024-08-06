varnish_vars <- function() {
  ver <- function(pak) glue::glue(" ({utils::packageVersion(pak)})")
  cfg <- function(pkg) {
    desc <- utils::packageDescription(pkg)
    url <- desc[["RemoteUrl"]]
    ref <- desc[["RemoteRef"]] %||% "HEAD" # if there is no ref, default to HEAD
    vsn <- desc[["Version"]]
    if (!is.null(url) && ref == vsn) {
      user <- "carpentries"
      repo <- pkg
    } else {
      user <- desc[["RemoteUsername"]]
      repo <- desc[["RemoteRepo"]]
    }
    if (is.null(user) || is.null(repo)) {
      return(NULL)
    }
    if (ref == "HEAD" && !is.null(desc[["RemoteSha"]])) {
      ref <- desc[["RemoteSha"]]
    }
    res <- paste0(user, "/", repo, "/tree/", ref)
    return(res)
  }
  res <- list(
    sandpaper_version = ver("sandpaper"),
    sandpaper_cfg     = cfg("sandpaper"),
    pegboard_version  = ver("pegboard"),
    pegboard_cfg      = cfg("pegboard"),
    varnish_version   = ver("varnish"),
    varnish_cfg       = cfg("varnish")
  )
  carpurl <- function(res, pkg) {
    config <- res[[paste0(pkg, "_cfg")]] %||% paste0("carpentries/", pkg)
    version <- res[[paste0(pkg, "_version")]]
    glue::glue('<a href="https://github.com/{config}">{pkg}{version}</a>')
  }
  urls <- list(
    sandpaper_link = carpurl(res, "sandpaper"),
    pegboard_link = carpurl(res, "pegboard"),
    varnish_link = carpurl(res, "varnish")
  )
  return(c(res, urls))

}

#' Set the necessary common global variables for use in the `{varnish}` template.
#'
#' This will enforce four global lists:
#'
#'  1. `.resources`, which is equivalent to the output of `get_resource_list()`
#'  2. `this_metadata`, which contains the metadata common for the lesson
#'  2. `learner_globals` the navigation items for the learners
#'  3. `instructor_globals` the namvigation items for the instructors
#'
#'  The things that are added:
#'
#'  - `sidebar` This is generated from [create_sidebar()] and is the same in the
#'    learner and instructor globals with the exception of the first element.
#'  - `more` This is the "More" dropdown menu, which is created via [create_resources_dropdown()].
#'  - `resources` The same as "More", but positioned on the mobile sidebar.
#'  - `{sandpaper,varnish,pegboard}_version` package versions of each package.
#'
#' @param path the path to the lesson
#'
#' @keywords internal
set_globals <- function(path) {
  template_check$set()
  initialise_metadata(path)
  # set the translations
  set_language(this_metadata$get()[["lang"]])
  # get the resources if they exist (but do not destroy the global environment)
  old <- .resources$get()
  on.exit(.resources$set(key = NULL, old))
  set_resource_list(path)
  these_resources <- .resources$get()

  # Sidebar information is largely duplicated across the views. The only thing
  # that is different is the name of the index node.
  idx <- these_resources[["."]]
  idx <- idx[as_html(idx) == "index.html"]
  instructor_sidebar <- create_sidebar(c(idx, these_resources[["episodes"]]))
  # check if we have a title in the index sidebar and replace with
  # "summary and schedule" if it does not exist.
  idx_item <- xml2::read_html(instructor_sidebar[[1]])
  idx_link <- xml2::xml_find_first(idx_item, ".//a")
  idx_text <- xml2::xml_contents(idx_link)
  no_index_title <- length(idx_text) == 1 && xml2::xml_text(idx_text) == "0. "
  if (no_index_title) {
    xml2::xml_set_text(idx_link, tr_computed("SummaryAndSchedule"))
  } else {
    xml2::xml_set_text(idx_text, sub("^0[.] ", "", xml2::xml_text(idx_text)))
  }
  sindex <- create_sidebar_item(nodes = NULL, as.character(idx_link), 1)
  learner_sidebar <- instructor_sidebar
  instructor_sidebar[[1]] <- sindex
  if (no_index_title) {
    xml2::xml_set_text(idx_link, tr_computed("SummaryAndSetup"))
    sindex <- create_sidebar_item(nodes = NULL, as.character(idx_link), 1)
  }
  learner_sidebar[[1]] <- sindex

  # Resources
  learner <- create_resources_dropdown(these_resources[["learners"]],
    "learners")
  instructor <- create_resources_dropdown(these_resources[["instructors"]],
    "instructors")
  instructor$extras <- c(instructor$extras, "<hr>", learner$extras)
  instructor$resources <- c(instructor$resources, "<hr>", learner$extras)
  pkg_versions <- varnish_vars()

  learner_globals$set(key = NULL,
    c(list(
      aio = TRUE,
      instructor = FALSE,
      sidebar = learner_sidebar,
      more = paste(learner$extras, collapse = ""),
      resources = paste(learner$resources, collapse = ""),
      translate = tr_varnish()
    ), pkg_versions)
  )
  instructor_globals$set(key = NULL,
    c(list(
      aio = TRUE,
      instructor = TRUE,
      sidebar = instructor_sidebar,
      more = paste(instructor$extras, collapse = ""),
      resources = paste(instructor$resources, collapse = ""),
      translate = tr_varnish()
    ), pkg_versions)
  )
}

setup_page_globals <- function() {
  instructor_local <- instructor_globals$copy()
  learner_local    <- learner_globals$copy()
  metadata_local   <- this_metadata$copy()
  return(list(
      instructor = instructor_local,
      learner = learner_local,
      metadata = metadata_local
  ))
}


clear_globals <- function() {
  learner_globals$clear()
  instructor_globals$clear()
  this_metadata$clear()
}
