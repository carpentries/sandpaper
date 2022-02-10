build_home <- function(pkg, quiet, sidebar = NULL, new_setup = TRUE, next_page = NULL) {
  page_globals <- setup_page_globals()
  path  <- root_path(pkg$src_path)
  syl   <- get_syllabus(path, questions = TRUE)
  cfg   <- get_config(path)
  idx      <- fs::path(pkg$src_path, "built", "index.md")
  readme   <- fs::path(pkg$src_path, "built", "README.md")
  idx_file <- if (fs::file_exists(idx)) idx else readme
  setup    <- fs::path(pkg$src_path, "built", "setup.md")
  index <- render_html(idx_file)
  if (fs::file_exists(setup)) {
    setup <- render_html(setup)
  } else {
    setup <- "<p></p>"
  }
  if (index != '') {
    html  <- xml2::read_html(index)
    fix_nodes(html)
  } else {
    html <- xml2::read_html("<p></p>")
  }
  setup <- xml2::read_html(setup)
  fix_nodes(setup)

  nav <- get_nav_data(idx_file, fs::path_file(idx_file), 
    page_forward = next_page)
  nav$pagetitle <- NULL
  page_globals$instructor$update(nav)
  page_globals$instructor$set("syllabus", paste(syl, collapse = ""))
  page_globals$instructor$set("readme", index)
  page_globals$learner$update(nav)
  page_globals$learner$set("readme", index)
  page_globals$learner$set("setup", setup)
  page_globals$metadata$update(nav)
  build_html(template = "syllabus", pkg, setup, page_globals, idx_file, quiet = quiet)

  # # render the page for instructor
  # if (!is.null(sidebar)) {
  #   sidebar[[1]] <- create_sidebar_item(html, "Summary and Schedule", "current")
  # }
  
  # json <- create_metadata_jsonld(path, 
  #   url = paste0(this_metadata$get()$url, "/instructor")
  # )

  
  # dat_instructor <- c(
  #   list(
  #     instructor = TRUE,
  #     this_page = "index.html",
  #     page_forward = fs::path_file(unname(next_page)),
  #     forward_title = get_trimmed_title(next_page),
  #     readme = use_instructor(html),
  #     syllabus = format_syllabus(syl, use_col = FALSE),
  #     more     = extras_menu(pkg$src_path, "instructors"),
  #     resources = extras_menu(pkg$src_path, "instructors", header = FALSE),
  #     pagetitle = parse_title(cfg$title),
  #     setup = NULL,
  #     json = json,
  #     sidebar = paste(sidebar, collapse = "")
  #   ),
  #   varnish_vars()
  # )

  # # shim for downlit
  # shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
  # expected <- "5484c37e9b9c324361d775a10dea4946"
  # actual   <- tools::md5sum(shimstem_file)
  # if (expected == actual) {
  #   # evaluate the shim in our namespace
  #   when_done <- source(shimstem_file, local = TRUE)$value
  #   on.exit(eval(when_done), add = TRUE)
  # }
  # # end downlit shim
  # ipath <- fs::path(pkg$dst_path, "instructor")
  # if (!fs::dir_exists(ipath)) fs::dir_create(ipath)

  # modified <- pkgdown::render_page(pkg, 
  #   "syllabus",
  #   data = dat_instructor,
  #   path = "instructor/index.html",
  #   depth = 1L,
  #   quiet = quiet
  # )
  # if (modified || new_setup) {
  #   # render the learner page
  #   sidebar[[1]] <- create_sidebar_item(setup, "Summary and Setup", "current")
  #   json <- create_metadata_jsonld()
  #   dat_learner <- modifyList(dat_instructor,
  #     list(
  #       instructor = FALSE,
  #       readme = use_learner(html),
  #       setup  = use_learner(setup),
  #       more = extras_menu(pkg$src_path, "learners"),
  #       resources = extras_menu(pkg$src_path, "learners", header = FALSE),
  #       syllabus = NULL,
  #       json = json,
  #       sidebar = paste(sidebar, collapse = "")
  #     )
  #   )
  #   modified <- pkgdown::render_page(pkg, 
  #     "syllabus",
  #     depth = 0L,
  #     data = dat_learner, 
  #     path = "index.html",
  #     quiet = quiet
  #   )
  # }
}


format_syllabus <- function(syl, use_col = TRUE) {
  syl$questions <- gsub("\n", "<br/>", syl$questions)
  syl$number <- sprintf("%2d\\. ", seq(nrow(syl)))
  links <- glue::glue_data(
    syl[-nrow(syl), ], 
    "{gsub('^[ ]', '&nbsp;', number)}<a href='{fs::path_file(path)}'>{episode}</a>"
  )
  if (use_col) {
    td_template <- "<td class='{cls}'>{thing}</td>"
  } else {
    td_template <- "<td>{thing}</td>"
    syl$timings <- glue::glue_data(
      syl,
      "<span class='visually-hidden'>Duration: </span>{timings}"
    )
  }
  td1 <- glue::glue(td_template, cls = "col-md-2", thing = syl$timings)
  td2 <- glue::glue(td_template, cls = "col-md-3", thing = c(links, "Finish"))
  td3 <- glue::glue(td_template, cls = "col-md-7", thing = syl$questions)
  out <- glue::glue_collapse(glue::glue("<tr>{td1}{td2}{td3}</tr>"), sep = "\n")
  tmp <- tempfile(fileext = ".md")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(out, tmp)
  render_html(tmp)
}
