tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp    <- fs::path(tmpdir, "lesson-example")

withr::defer({
  if (fs::is_dir(tmp))
    fs::dir_delete(tmp)
  else
    fs::dir_delete(tmpdir)
})

test_that("the formatted syllabus renders markdown", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp, open = FALSE, rstudio = FALSE)
  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)

  res <- get_syllabus(tmp, questions = TRUE)
  fmt <- format_syllabus(res)

  expect_type(fmt, "character")
  expect_length(fmt, 1)
  expect_true(grepl("<code>{sandpaper}</code>", fmt, fixed  = TRUE))

})

