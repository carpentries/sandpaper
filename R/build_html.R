build_html <- function(template = "chapter", pkg, nodes, global_data, path_md, quiet = TRUE) {
  # shim for downlit ----------------------------------------------------------
  shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
  expected <- "5484c37e9b9c324361d775a10dea4946"
  actual   <- tools::md5sum(shimstem_file)
  if (expected == actual) {
    # evaluate the shim in our namespace
    when_done <- source(shimstem_file, local = TRUE)$value
    on.exit(eval(when_done), add = TRUE)
  }
  # end downlit shim ----------------------------------------------------------
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
