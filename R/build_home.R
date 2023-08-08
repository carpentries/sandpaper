build_home <- function(pkg, quiet, next_page = NULL) {
  page_globals <- setup_page_globals()
  path  <- root_path(pkg$src_path)
  syl   <- format_syllabus(get_syllabus(path, questions = TRUE),
    use_col = FALSE)
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

  nav <- get_nav_data(idx_file, fs::path_file(idx_file), page_forward = next_page)
  needs_title <- nav$pagetitle == ""

  if (needs_title) {
    nav$pagetitle <- "Summary and Schedule"
  }
  nav$page_forward <- as_html(nav$page_forward, instructor = TRUE)
  page_globals$instructor$update(nav)
  page_globals$instructor$set("syllabus", paste(syl, collapse = ""))
  page_globals$instructor$set("readme", use_instructor(html))
  page_globals$instructor$set("setup", use_instructor(setup))

  if (needs_title) {
    nav$pagetitle <- "Summary and Setup"
  }
  nav$page_forward <- as_html(nav$page_forward)
  page_globals$learner$update(nav)
  page_globals$learner$set("readme", use_learner(html))
  page_globals$learner$set("setup", use_learner(setup))

  nav$pagetitle <- NULL
  page_globals$metadata$update(nav)

  build_html(template = "syllabus", pkg = pkg, nodes = list(html, setup),
    global_data = page_globals, path_md = "index.html", quiet = quiet)

}


format_syllabus <- function(syl, use_col = TRUE) {
  if (nrow(syl) == 0L) {
    return("<p></p>")
  }
  syl$questions <- gsub("\n", "<br/>", syl$questions)
  syl$number <- sprintf("%2d\\. ", seq(nrow(syl)))
  links <- glue::glue_data(
    syl[-nrow(syl), c("number", "episode", "path")],
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
  return(render_html(tmp))
}
