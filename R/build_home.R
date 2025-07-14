#' Build a home page for a lesson
#'
#' @param pkg a list generated from [pkgdown::as_pkgdown()] from the `site/`
#'   folder of a lesson.
#' @param quiet a boolean passed to [build_html()]. if `TRUE`, this will have
#'   pkgdown report what files are being built
#' @param next_page the next page file name. This will allow the navigation
#'   element to be set up correctly on the navigation bar
#' @return nothing. This is used for its side-effect
#'
#' @keywords internal
#' @details The index page of the lesson is a combination of two pages:
#'
#'   1. index.md (or README if the index does not exist)
#'   2. learners/setup.md
#'
#' This function uses [render_html()] to convert the page into HTML, which gets
#' passed on to the "syllabus" or "overview" templates in `{varnish}` (via the
#' [build_html()] function as the `{{{ readme }}}` and `{{{ setup }}}` keys.
build_home <- function(pkg, quiet, next_page = NULL) {
  page_globals <- setup_page_globals()
  path  <- get_source_path() %||% root_path(pkg$src_path)
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

  idx_src <- fs::path(path, fs::path_file(idx_file))
  nav <- get_nav_data(idx_file, idx_src, page_forward = next_page)
  needs_title <- nav$pagetitle == ""

  if (needs_title) {
    nav$pagetitle <- tr_computed("SummaryAndSchedule")
  }
  nav$page_forward <- as_html(nav$page_forward, instructor = TRUE)
  page_globals$instructor$update(nav)
  page_globals$instructor$set("syllabus", paste(syl, collapse = ""))
  page_globals$instructor$set("readme", use_instructor(html))
  page_globals$instructor$set("setup", use_instructor(setup))

  if (needs_title) {
    nav$pagetitle <- tr_computed("SummaryAndSetup")
  }
  nav$page_forward <- as_html(nav$page_forward)
  page_globals$learner$update(nav)
  page_globals$learner$set("readme", use_learner(html))
  page_globals$learner$set("setup", use_learner(setup))

  nav$pagetitle <- NULL
  page_globals$metadata$update(nav)
  is_overview <- identical(page_globals$metadata$get()$overview, TRUE)
  if (is_overview) {
    template <- "overview"
  } else {
    template <- "syllabus"
  }

  build_html(template = template, pkg = pkg, nodes = list(html, setup),
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
  td2 <- glue::glue(td_template, cls = "col-md-3",
    thing = c(links, tr_computed("Finish")))
  td3 <- glue::glue(td_template, cls = "col-md-7", thing = syl$questions)
  out <- glue::glue_collapse(glue::glue("<tr>{td1}{td2}{td3}</tr>"), sep = "\n")
  tmp <- tempfile(fileext = ".md")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(out, tmp)
  return(render_html(tmp))
}
