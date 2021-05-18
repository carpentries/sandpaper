test_that("lessons can be built sanely", {
  
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp, open = FALSE)
  create_episode("second-episode", path = tmp)
  expect_warning(s <- get_episodes(tmp), "set_episodes")
  set_episodes(tmp, s, write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)

  # It's noisy at first
  suppressMessages({
    expect_output(build_lesson(res, preview = FALSE, quiet = FALSE), "ordinary text without R code")
  })

  # see helper-hash.R
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_equal(h1, h2, ignore_attr = TRUE)

  sitepath <- fs::path(tmp, "site", "docs")
  expect_true(fs::file_exists(fs::path(sitepath, "01-introduction.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "02-second-episode.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "index.html")))
  ep <- readLines(fs::path(sitepath, "01-introduction.html"))

  # Div tags show up as expected
  expect_true(any(grepl(".div class..challenge", ep)))
  # figure captions show up from knitr 
  # (https://github.com/carpentries/sandpaper/issues/114) 
  expect_true(any(grepl("Sun arise each and every morning", ep)))
  expect_true(any(grepl(
        ".div class..challenge", 
        readLines(fs::path(sitepath, "02-second-episode.html"))
  )))
  expect_true(any(grepl(
        "02-second-episode.html",
        readLines(fs::path(sitepath, "index.html"))
  )))

  # But will not built if things are not changed
  expect_failure(
    expect_output(build_lesson(res, preview = FALSE), "ordinary text without R code")
  )
  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))
  expect_failure(
    expect_output(build_lesson(res, preview = FALSE), "ordinary text without R code")
  )

  expect_true(fs::file_exists(fs::path(sitepath, "01-introduction.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "02-second-episode.html")))

  # If index.md exists, it will use that for the index
  writeLines("I am an INDEX\n", fs::path(res, "index.md"))
  build_lesson(res, quiet = TRUE, preview = FALSE)

  expect_true(any(grepl(
        "I am an INDEX",
        readLines(fs::path(sitepath, "index.html"))
  )))

})


test_that("episodes with HTML in the title are rendered correctly", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp, open = FALSE)
  create_episode("second-episode", path = tmp)
  expect_warning(s <- get_episodes(tmp), "set_episodes")
  set_episodes(tmp, s, write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)

  se <- readLines(fs::path(tmp, "episodes", "02-second-episode.Rmd"))
  se[[2]] <- "title: A **bold** title"
  writeLines(se, fs::path(tmp, "episodes", "02-second-episode.Rmd"))

  suppressMessages({
  expect_output(build_lesson(res, preview = FALSE, quiet = FALSE), "ordinary text without R code")
  })

  sitepath <- fs::path(tmp, "site", "docs")

  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_failure(expect_equal(h1, h2, ignore_attr = TRUE))
  expect_true(fs::file_exists(fs::path(sitepath, "02-second-episode.html")))

  expect_true(any(grepl(
        "A <strong>bold</strong> title", 
        readLines(fs::path(sitepath, "02-second-episode.html")),
        fixed = TRUE
  )))
})
