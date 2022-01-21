build_keypoints <- function(pkg, quiet, sidebar = NULL) {
  path <- root_path(pkg$src_path)
  lesson <- this_lesson(path)
  keys <- vapply(lesson$episodes, function(i) {
    title <- i$get_yaml()$title
    keys  <- i$keypoints
    kp <- "No keypoints"
    if (length(keys) > 1) {
      kp <- paste("-", i$keypoints, collapse = "\n")
    }
    md <- paste0("## [", title, "](", as_html(i$name) ,")\n\n", kp, "\n\n")
    return(md)
  }, character(1))

  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  writeLines(keys, tmp)

  html <- xml2::read_html(render_html(tmp))
  fix_nodes(html)

  # render the page for instructor
  if (!is.null(sidebar)) {
    name <- "<a href='index.html'>Summary and Schedule</a>"
    sidebar[[1]] <- create_sidebar_item(NULL, name, 1)
  }

  json <- create_metadata_jsonld(path, 
    pagetitle = "Keypoints",
    url = paste0(this_metadata$get()$url, "/instructor/key-points.html")
  )

  dat_instructor <- c(
    list(
      instructor = TRUE,
      more = extras_menu(pkg$src_path, "instructors"),
      this_page = "key-points.html",
      body = use_instructor(html),
      pagetitle = "Keypoints",
      json = json,
      sidebar = paste(sidebar, collapse = "")
    ),
    varnish_vars()
  )

  # shim for downlit
  shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
  expected <- "5484c37e9b9c324361d775a10dea4946"
  actual   <- tools::md5sum(shimstem_file)
  if (expected == actual) {
    # evaluate the shim in our namespace
    when_done <- source(shimstem_file, local = TRUE)$value
    on.exit(eval(when_done), add = TRUE)
  }
  # end downlit shim

  ipath <- fs::path(pkg$dst_path, "instructor")
  if (!fs::dir_exists(ipath)) fs::dir_create(ipath)

  modified <- pkgdown::render_page(pkg,
    "extra",
    data = dat_instructor,
    path = "instructor/key-points.html",
    depth = 1L,
    quiet = quiet
  )
  if (modified || !fs::file_exists(fs::path(pkg$dst_path, "key-points.html"))) {
    name <- "<a href='index.html'>Summary and Setup</a>"
    sidebar[[1]] <- create_sidebar_item(NULL, name, 1)
    json <- create_metadata_jsonld(path, 
      pagetitle = "Keypoints",
      url = paste0(this_metadata$get()$url, "/key-points.html")
    )
    dat_learner <- modifyList(dat_instructor,
      list(
        instructor = FALSE,
        more = extras_menu(pkg$src_path, "learners"),
        body = use_learner(html),
        syllabus = NULL,
        sidebar = paste(sidebar, collapse = "")
      )
    )
    modified <- pkgdown::render_page(pkg,
      "extra",
      depth = 0L,
      data = dat_learner, 
      path = "key-points.html",
      quiet = quiet
    )
  }
}
