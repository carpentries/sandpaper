{
q <- "How do you write a lesson using R Markdown and `{sandpaper}`?"
tmp <- res <- restore_fixture()
}

test_that("syllabus can be extracted from source files", {

  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)

  # testing that create_esyllabus is independent
  lsn <- pegboard::Lesson$new(tmp, jekyll = FALSE)
  res <- create_syllabus(s, lesson = lsn)
  expect_named(res, c("episode", "timings", "path", "percents", "questions"))
  expect_equal(nrow(res), 2)
  expect_equal(res$timings, c("00h 00m", "00h 12m"))
  expect_equal(res$episode, c("introduction", "Finish"))
  expect_equal(fs::path_file(res$path), c("introduction.html", ""))
})

test_that("syllabus will update with new files", {

  create_episode("postroduction", path = tmp, add = TRUE)
  res <- get_syllabus(tmp, questions = TRUE)
  expect_named(res, c("episode", "timings", "path", "percents", "questions"))
  expect_equal(nrow(res), 3)
  expect_equal(res$timings, c("00h 00m", "00h 12m", "00h 24m"))
  expect_equal(res$percents, c("0", "50", "100"))
  expect_equal(res$episode, c("introduction", "postroduction", "Finish"))
  expect_equal(fs::path_file(res$path), c("introduction.html", "postroduction.html", ""))
  expect_equal(res$questions, c(rep(q, 2), ""))
  
})

test_that("episodes missing question blocks do not throw error", {

  writeLines(
    "---\ntitle: Break\nteaching: 42\nexercises: 0\n---\n\nThis should not error.",
    fs::path(tmp, "episodes", "break.md")
  )

  set_episodes(tmp, c(get_episodes(tmp), "break.md"), write = TRUE)

  expect_warning(res <- get_syllabus(tmp, questions = TRUE))
  expect_equal(nrow(res), 4)
  expect_equal(res$timings, c("00h 00m", "00h 12m", "00h 24m", "01h 06m"))
  expect_equal(res$percents, c("0", "18", "36", "100"))
  expect_equal(res$episode, c("introduction", "postroduction", "Break", "Finish"))
  expect_equal(fs::path_file(res$path), c("introduction.html", "postroduction.html", "break.html", ""))
  expect_equal(res$questions, c(rep(q, 2), "", ""))

})
