{
tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp <- fs::path(tmpdir, "lesson-example")
q <- "How do you write a lesson using RMarkdown and `{sandpaper}`?"
withr::defer(fs::dir_delete(tmp))
res <- create_lesson(tmp, open = FALSE, rstudio = FALSE)
}

test_that("syllabus can be extracted from source files", {

  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)

  res <- get_syllabus(tmp)
  expect_named(res, c("episode", "timings", "path"))
  expect_equal(nrow(res), 2)
  expect_equal(res$timings, c("00:00", "00:12"))
  expect_equal(res$episode, c("Using RMarkdown", "Finish"))
  expect_equal(fs::path_file(res$path), c("01-introduction.html", ""))
})

test_that("syllabus will update with new files", {

  create_episode("postroduction", path = tmp, add = TRUE)
  res <- get_syllabus(tmp, questions = TRUE)
  expect_named(res, c("episode", "timings", "path", "questions"))
  expect_equal(nrow(res), 3)
  expect_equal(res$timings, c("00:00", "00:12", "00:24"))
  expect_equal(res$episode, c(rep("Using RMarkdown", 2), "Finish"))
  expect_equal(fs::path_file(res$path), c("01-introduction.html", "02-postroduction.html", ""))
  expect_equal(res$questions, c(rep(q, 2), ""))
  
})

test_that("episodes missing question blocks do not throw error", {

  writeLines(
    "---\ntitle: Break\nteaching: 0\nexercises: 0\n---\n\nThis should not error.",
    fs::path(tmp, "episodes", "break.md")
  )

  set_episodes(tmp, c(get_episodes(tmp), "break.md"), write = TRUE)

  expect_warning(res <- get_syllabus(tmp, questions = TRUE))
  expect_equal(nrow(res), 4)
  expect_equal(res$timings, c("00:00", "00:12", "00:24", "00:24"))
  expect_equal(res$episode, c(rep("Using RMarkdown", 2), "Break", "Finish"))
  expect_equal(fs::path_file(res$path), c("01-introduction.html", "02-postroduction.html", "break.html", ""))
  expect_equal(res$questions, c(rep(q, 2), "", ""))

})
