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

test_that("episodes missing question blocks and timings do not throw error", {

  # preamble: create two empty episodes, one in draft with n timings, and one
  # with timings, but no break.
  writeLines(
    "---\ntitle: Draft\nteaching: XX\n---\n\nThis should not error.",
    fs::path(tmp, "episodes", "draft.md")
  )
  writeLines(
    "---\ntitle: Break\nteaching: 0\nexercises: 0\nbreak: 15\n---\n\nHave a nice cold coffee.",
    fs::path(tmp, "episodes", "break.md")
  )

  # "introduction", "postroduction", "draft", "break"
  expected <- c(get_episodes(tmp), "draft.md", "break.md")
  set_episodes(tmp, expected, write = TRUE)

  expect_snapshot(res <- get_syllabus(tmp, questions = TRUE))

  # output is a table with five rows
  expect_equal(nrow(res), 5)

  expect_equal(res$timings,
    c("00h 00m", "00h 12m", "00h 24m", "00h 34m", "00h 49m"))
  expect_equal(res$percents,
    c("0", "24", "49", "69", "100"))
  expect_equal(res$episode,
    c("introduction", "postroduction", "Draft", "Break", "Finish"))

  # path is the path to the the HTML file from the root of the site
  expect_equal(fs::path_file(res$path),
    c(fs::path_ext_set(expected, "html"), ""))

  # q is defined at the top of this file and files with no questions are blank
  expect_equal(res$questions,
    c(rep(q, 2), "",  "", ""))

})
