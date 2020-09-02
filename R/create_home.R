create_home <- function(path) {
  check_lesson(path)
  syl   <- get_syllabus(path, questions = TRUE)
  index <- html_from_md(fs::path(path, "README.md"))
  c(index, format_syllabus(syl))
}


format_syllabus <- function(syl) {

  syl$questions <- gsub("\n", "<br/>", syl$questions)
  col_template <- "<td class='{cls}'>{thing}</td>"
  links <- glue::glue_data(syl, "<a href='{fs::path_file(path)}'>{episode}</a>")
  md2 <- glue::glue(col_template, cls = "col-md-2", thing = syl$timings)
  md3 <- glue::glue(col_template, cls = "col-md-3", thing = links)
  md7 <- glue::glue(col_template, cls = "col-md-7", thing = syl$questions)
  glue::glue_collapse(glue::glue("<tr>{md2}{md3}{md7}</tr>"))

}
