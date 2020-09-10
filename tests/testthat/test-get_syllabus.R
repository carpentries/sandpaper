test_that("syllabus can be extracted from source files", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp, open = FALSE, rstudio = FALSE)
  expect_warning(s <- get_schedule(tmp), "set_schedule")
  set_schedule(tmp, s, write = TRUE)

  res <- get_syllabus(tmp)
  expect_named(res, c("episode", "timings", "path"))
  expect_equal(nrow(res), 2)
  expect_equal(res$timings, c("00:00", "00:12"))
  expect_equal(res$episode, c("Using RMarkdown", "Finish"))
  expect_equal(fs::path_file(res$path), c("01-introduction.html", ""))

  q <- "How do you write a lesson using RMarkdown with `{dovetail}` and `{sandpaper}`?"
  create_episode("postroduction", path = tmp, add = TRUE)
  res <- get_syllabus(tmp, questions = TRUE)
  expect_named(res, c("episode", "timings", "path", "questions"))
  expect_equal(nrow(res), 3)
  expect_equal(res$timings, c("00:00", "00:12", "00:24"))
  expect_equal(res$episode, c(rep("Using RMarkdown", 2), "Finish"))
  expect_equal(fs::path_file(res$path), c("01-introduction.html", "02-postroduction.html", ""))
  expect_equal(res$questions, c(rep(q, 2), ""))
  
})
