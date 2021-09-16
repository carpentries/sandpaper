build_home <- function(pkg, quiet) {
  path  <- root_path(pkg$src_path)
  syl   <- get_syllabus(path, questions = TRUE)
  idx      <- fs::path(pkg$src_path, "built", "index.md")
  readme   <- fs::path(pkg$src_path, "built", "README.md")
  index <- render_html(if (fs::file_exists(idx)) idx else readme)
  pkgdown::render_page(pkg, 
    "syllabus",
    data = c(
      list(
        readme = index,
        syllabus = format_syllabus(syl)
      ),
      varnish_vars()
    ), 
    path = "index.html",
    quiet = quiet
  )
}


format_syllabus <- function(syl) {
  syl$questions <- gsub("\n", "<br/>", syl$questions)
  syl$number <- sprintf("%2d\\. ", seq(nrow(syl)))
  col_template <- "<td class='{cls}'>{thing}</td>"
  links <- glue::glue_data(
    syl[-nrow(syl), ], 
    "{gsub('^[ ]', '&nbsp;', number)}<a href='{fs::path_file(path)}'>{episode}</a>"
  )
  md2 <- glue::glue(col_template, cls = "col-md-2", thing = syl$timings)
  md3 <- glue::glue(col_template, cls = "col-md-3", thing = c(links, "Finish"))
  md7 <- glue::glue(col_template, cls = "col-md-7", thing = syl$questions)
  out <- glue::glue_collapse(glue::glue("<tr>{md2}{md3}{md7}</tr>"), sep = "\n")
  tmp <- tempfile(fileext = ".md")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(out, tmp)
  render_html(tmp)
}
