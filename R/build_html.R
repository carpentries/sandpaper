#' Build instructor and learner HTML page
#'
#' @param template the name of the {varnish} template to use. Defaults to
#'   "chapter"
#' @param pkg an object created from  [pkgdown::as_pkgdown()]
#' @param nodes an `xml_document` object. In the case of using this for the
#'   index page (from [build_home()]), `nodes` will be a list of two
#'   `xml_documents`; one for instructors and one for learners so that the
#'   instructors have the schedule available to them (however, this might be a
#'   relic, Zhian needs to inspect it).
#' @param global_data a list store object that contains copies of the global
#'   variables for the page, including metadata, navigation, and variables for
#'   the {varnish} templates.
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
#' engine: {pkgdown}. It will perform the global operations that includes
#' setting up the navigation, adding metadata, and building both the instructor
#' and learner versions of the page.
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
  update_sidebar(global_data$instructor, instructor_nodes, path_md)
  meta$set("url", paste0(base_url, this_page))
  global_data$instructor$set("json", fill_metadata_template(meta))
  modified <- pkgdown::render_page(pkg,
    template,
    data = global_data$instructor$get(),
    depth = 1L,
    path = this_page,
    quiet = quiet
  )

  # Process learner page if needed ---------------------------------------------
  if (modified) {
    this_page <- as_html(this_page)
    update_sidebar(global_data$learner, learner_nodes, path_md)
    meta$set("url", paste0(base_url, this_page))
    global_data$learner$set("json", fill_metadata_template(meta))
    pkgdown::render_page(pkg,
      template,
      data = global_data$learner$get(),
      depth = 0L,
      path = this_page,
      quiet = quiet
    )
  }
}
