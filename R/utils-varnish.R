varnish_vars <- function() {
  ver <- function(pak) glue::glue(" ({packageVersion(pak)})")
  list(
    sandpaper_version = ver("sandpaper"),
    pegboard_version  = ver("pegboard"),
    varnish_version   = ver("varnish")
  )
}

#' Set the necessary common global variables for use in the {varnish} template. 
#' 
#' This will enforce three global lists:
#'
#'  1. `.resources`, which is equivalent to the output of `get_source_list()`
#'  2. `learner_globals` the navigation items for the learners
#'  3. `instructor_globals` the namvigation items for the instructors
#'
#'  The things that are added:
#'
#'  - `sidebar` This is generated from [create_sidebar()] and is the same in the
#'    learner and instructor globals
#'  - `more` This is the "More" dorpdown menu, which is created via [create_resources_dropdown()].
#'  - `resources` The same as "More", but positioned on the mobile sidebar. 
#'  - `{sandpaper,varnish,pegboard}_version` package versions of each package.
#'
#' @param path the path to the lesson
#'
#' @keywords internal
set_globals <- function(path) {
  # get the resources if they exist (but do not destroy the global environment)
  old <- .resources$get()
  on.exit(.resources$set(key = NULL, old))
  set_resource_list(path)
  these_resources <- .resources$get()

  sidebar <- create_sidebar(these_resources[["episodes"]])
  learner <- create_resources_dropdown(these_resources[["learners"]], 
    "learners")
  instructor <- create_resources_dropdown(these_resources[["instructors"]], 
    "instructors")
  pkg_versions <- varnish_vars()

  learner_globals$set(key = NULL, 
    c(list(
      sidebar = sidebar,
      more = learner$extras,
      resources = learner$resources
    ), pkg_versions)
  )
  instructor_globals$set(key = NULL, 
    c(list(
      sidebar = sidebar,
      more = instructor$extras,
      resources = instructor$resources
    ), pkg_versions)
  )
}


clear_globals <- function() {
  learner_globals$clear()
  instructor_globals$clear()
}

