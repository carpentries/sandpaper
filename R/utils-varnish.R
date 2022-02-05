varnish_vars <- function() {
  ver <- function(pak) glue::glue(" ({packageVersion(pak)})")
  list(
    sandpaper_version = ver("sandpaper"),
    pegboard_version  = ver("pegboard"),
    varnish_version   = ver("varnish")
  )
}

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

