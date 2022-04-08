varnish_vars <- function() {
  ver <- function(pak) glue::glue(" ({packageVersion(pak)})")
  cfg <- function(pkg) {
    desc <- packageDescription(pkg)
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
  list(
    sandpaper_version = ver("sandpaper"),
    sandpaper_cfg     = cfg("sandpaper"),
    pegboard_version  = ver("pegboard"),
    varnish_version   = ver("varnish"),
    varnish_cfg       = cfg("varnish")
  )
}

#' Set the necessary common global variables for use in the {varnish} template. 
#' 
#' This will enforce four global lists:
#'
#'  1. `.resources`, which is equivalent to the output of `get_source_list()`
#'  2. `this_metadata`, which contains the metadata common for the lesson
#'  2. `learner_globals` the navigation items for the learners
#'  3. `instructor_globals` the namvigation items for the instructors
#'
#'  The things that are added:
#'
#'  - `sidebar` This is generated from [create_sidebar()] and is the same in the
#'    learner and instructor globals with the exception of the first element.
#'  - `more` This is the "More" dorpdown menu, which is created via [create_resources_dropdown()].
#'  - `resources` The same as "More", but positioned on the mobile sidebar. 
#'  - `{sandpaper,varnish,pegboard}_version` package versions of each package.
#'
#' @param path the path to the lesson
#'
#' @keywords internal
set_globals <- function(path) {
  initialise_metadata(path)
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
  learner_sidebar <- instructor_sidebar
  sindex <- create_sidebar_item(nodes = NULL,
    "<a href='index.html'>Summary and Schedule</a>", 1)
  instructor_sidebar[[1]] <- sindex
  learner_sidebar[[1]] <- sub("Schedule", "Setup", sindex)

  # Resources
  learner <- create_resources_dropdown(these_resources[["learners"]], 
    "learners")
  instructor <- create_resources_dropdown(these_resources[["instructors"]], 
    "instructors")
  pkg_versions <- varnish_vars()

  learner_globals$set(key = NULL, 
    c(list(
      instructor = FALSE,
      sidebar = learner_sidebar,
      more = paste(learner$extras, collapse = ""),
      resources = paste(learner$resources, collapse = "")
    ), pkg_versions)
  )
  instructor_globals$set(key = NULL, 
    c(list(
      instructor = TRUE,
      sidebar = instructor_sidebar,
      more = paste(instructor$extras, collapse = ""),
      resources = paste(instructor$resources, collapse = "")
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

