build_html <- function(nodes, dat_instructor, dat_learner) {
  # ------------------------------------------------- Run pkgdown::render_page()
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
    "chapter",
    data = dat_instructor$get(),
    depth = 1L,
    path = this_page,
    quiet = quiet
  )

  if (modified) {
    if (!is.null(sidebar)) {
      idx <- "<a href='index.html'>Summary and Setup</a>"
      sidebar[[1]] <- create_sidebar_item(nodes, idx, 1)
    }

    json <- create_metadata_jsonld(home, 
      date = list(modified = date),
      pagetitle = title,
      url = paste0(this_metadata$get()$url, "/", as_html(this_page))
    )

    # we only need to compute the learner page if the instructor page has
    # modified since the instructor material contains more information and thus
    # more things to modify.

    learner_list <- modifyList(instructor_list,
      list(
        body = use_learner(nodes),
        instructor = FALSE,
        page_back = fs::path_file(page_back), 
        page_forward = fs::path_file(page_forward), 
        json         = json,
        sidebar      = paste(gsub("instructor/", "", sidebar), collapse = "\n")
      )
    )

    dat_learner <- learner_globals$copy()
    dat_learner$update(learner_list)
    pkgdown::render_page(pkg, 
      "chapter",
      data = dat_learner$get(),
      depth = 0L,
      path = as_html(this_page),
      quiet = quiet
    )
  }
}
