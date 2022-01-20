build_profiles <- function(pkg, quiet, sidebar = NULL) {
  path <- root_path(pkg$src_path)
  profs <- get_profiles(path, trim = FALSE)
  html <- paste(vapply(profs, render_html, character(1)), collapse = "<hr>")
  if (html != '') {
    html  <- xml2::read_html(html)
    fix_nodes(html)
  } else {
    html <- xml2::read_html("<p>No learner profiles yet!</p>")
  }
  # render the page for instructor
  if (!is.null(sidebar)) {
    name <- "<a href='index.html'>Summary and Schedule</a>"
    sidebar[[1]] <- create_sidebar_item(NULL, name, 1)
  }

  dat_instructor <- c(
    list(
      instructor = TRUE,
      more = extras_menu(pkg$src_path, "instructors"),
      this_page = "profiles.html",
      body = use_instructor(html),
      pagetitle = "Learner Profiles",
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
    path = "instructor/profiles.html",
    depth = 1L,
    quiet = quiet
  )
  if (modified || !fs::file_exists(fs::path(pkg$dst_path, "profiles.html"))) {
    name <- "<a href='index.html'>Summary and Setup</a>"
    sidebar[[1]] <- create_sidebar_item(NULL, name, 1)
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
      path = "profiles.html",
      quiet = quiet
    )
  }
}

