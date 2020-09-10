test_that("the formatted syllabus renders markdown", {

  
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp, open = FALSE, rstudio = FALSE)
  expect_warning(s <- get_schedule(tmp), "set_schedule")
  set_schedule(tmp, s, write = TRUE)

  res <- get_syllabus(tmp, questions = TRUE)
  fmt <- format_syllabus(res)

  expect_type(fmt, "character")
  expect_length(fmt, 1)
  expect_true(grepl("<code>{dovetail}</code>", fmt, fixed  = TRUE))
  

})
