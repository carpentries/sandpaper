tmp <- res <- restore_fixture()

test_that("the formatted syllabus renders markdown", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  
  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)

  res <- get_syllabus(tmp, questions = TRUE)
  fmt <- format_syllabus(res)

  expect_type(fmt, "character")
  expect_length(fmt, 1)
  expect_true(grepl("<code>{sandpaper}</code>", fmt, fixed  = TRUE))

})

