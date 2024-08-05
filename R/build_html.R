#' Build instructor and learner HTML page
#'
#' @param template the name of the `{varnish}` template to use. Defaults to
#'   "chapter"
#' @param pkg an object created from  [pkgdown::as_pkgdown()]
#' @param nodes an `xml_document` object. `nodes` will be a list of two
#'   `xml_documents`; one for instructors and one for learners so that the
#'   instructors have the schedule available to them. If both the instructor
#'   and learner page, it will be a single `xml_document` object.
#' @param global_data a list store object that contains copies of the global
#'   variables for the page, including metadata, navigation, and variables for
#'   the `{varnish}` templates.
#' @param path_md the path (absolute, relative, or filename) the current
#'   markdown file being processed.
#' @param quiet This parameter is passed to [pkgdown::render_page()] and will
#'   print the progress if `TRUE` (default).
#' @return `TRUE` if the page was built and `NULL` if it did not need to be
#' rebuilt
#' @keywords internal
#'
#' @details This function is a central workhorse that connects the global
#' lesson metadata and the global variables for each page to the rendering
#' engine: `{pkgdown}`. It will perform the global operations that includes
#' setting up the navigation (via [update_sidebar()]), adding metadata, and
#' building both the instructor and learner versions of the page (via
#' [pkgdown::render_page()]).
#'
#' In the Workbench, there are three types of pages:
#'
#' 1. primary content pages: these are primary content with a 1:1 relationship
#'    between the source and the output. These are episodes along with custom
#'    learner and instructor content
#' 2. aggregate content pages: pages that are aggregated from other pages such
#'    as key points, all-in-one, images
#' 3. concatenated content pages: concatenations of source files and potentially
#'    aggregate data. Examples are index, learner profiles, and the instructor
#'    notes pages.
#'
#' Each of these types of pages have their own process for setting up content,
#' which gets processed before its passed here.
#' @seealso [set_globals()] for definitions of the global data,
#'   [update_sidebar()] for context of how the sidebar is updated,
build_html <- function(template = "chapter", pkg, nodes, global_data, path_md, quiet = TRUE) {
  ipath <- fs::path(pkg$dst_path, "instructor")
  if (!fs::dir_exists(ipath)) fs::dir_create(ipath)

  this_page <- as_html(path_md, instructor = TRUE)
  meta <- global_data$metadata
  base_url <- meta$get()$url

  # Handle the differences between instructor and learner views for the index page
  if (inherits(nodes, "xml_document")) {
    instructor_nodes <- nodes
    learner_nodes <- nodes
  } else {
    instructor_nodes <- nodes[[1]]
    learner_nodes <- nodes[[2]]
  }

  # Process instructor page ----------------------------------------------------
  update_sidebar(global_data$instructor, instructor_nodes, fs::path_file(this_page))
  meta$set("url", paste0(base_url, this_page))
  translated <- fill_translation_vars(global_data$instructor$get())
  global_data$instructor$set("json", fill_metadata_template(meta))
  global_data$instructor$set("translate", translated)
  global_data$instructor$set("citation", meta$get()$citation)

  # add tracker script
  global_data$instructor$set("analytics", processTracker(meta$get()$analytics))

  modified <- pkgdown::render_page(pkg,
    template,
    data = global_data$instructor$get(),
    depth = 1L,
    path = this_page,
    quiet = quiet
  )

  # Process learner page if needed ---------------------------------------------
  if (modified) {
    global_data$learner$set("translate", translated)
    this_page <- as_html(this_page)
    update_sidebar(global_data$learner, learner_nodes, fs::path_file(this_page))
    meta$set("url", paste0(base_url, this_page))
    global_data$learner$set("json", fill_metadata_template(meta))
    global_data$learner$set("citation", meta$get()$citation)

    # add tracker script
    global_data$learner$set("analytics", processTracker(meta$get()$analytics))

    pkgdown::render_page(pkg,
      template,
      data = global_data$learner$get(),
      depth = 0L,
      path = this_page,
      quiet = quiet
    )
  }
}
