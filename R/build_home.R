build_home <- function(pkg, quiet) {
  path  <- root_path(pkg$src_path)
  syl   <- get_syllabus(path, questions = TRUE)
  cfg   <- get_config(path)
  idx      <- fs::path(pkg$src_path, "built", "index.md")
  readme   <- fs::path(pkg$src_path, "built", "README.md")
  index <- render_html(if (fs::file_exists(idx)) idx else readme)
  pkgdown::render_page(pkg, 
    "syllabus",
    data = c(
      list(
        readme = index,
        syllabus = format_syllabus(syl),
        pagetitle = parse_title(cfg$title)
      ),
      varnish_vars()
    ), 
    path = "index.html",
    quiet = quiet
  )
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
