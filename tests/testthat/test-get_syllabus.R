test_that("syllabus can be extracted from source files", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp, open = FALSE, rstudio = FALSE)

  res <- get_syllabus(tmp)
  expect_named(res, c("episode", "timings", "path"))
  expect_equal(nrow(res), 1)
  expect_equal(res$timings, "00:12")
  expect_equal(res$episode, "Using RMarkdown")
  expect_equal(fs::path_file(res$path), "01-introduction.html")

  q <- "How do you write a lesson using RMarkdown with {dovtail} and {sandpaper}?"
  create_episode("postroduction", path = tmp)
  res <- get_syllabus(tmp, questions = TRUE)
  expect_named(res, c("episode", "timings", "path", "questions"))
  expect_equal(nrow(res), 2)
  expect_equal(res$timings, c("00:12", "00:24"))
  expect_equal(res$episode, rep("Using RMarkdown", 2))
  expect_equal(fs::path_file(res$path), c("01-introduction.html", "02-postroduction.html"))
  expect_equal(res$questions, rep(q, 2))
  
})
