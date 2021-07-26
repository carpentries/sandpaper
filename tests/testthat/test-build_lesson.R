
tmp <- res <- restore_fixture()
sitepath <- fs::path(tmp, "site", "docs")


test_that("Lessons built for the first time are noisy", {
  
  create_episode("second-episode", path = tmp)
  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # It's noisy at first
  suppressMessages({
    expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE), 
      "ordinary text without R code")
  })

})

test_that("source files are hashed", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # see helper-hash.R
  h1 <- expect_hashed(tmp, "01-introduction.Rmd")
  h2 <- expect_hashed(tmp, "02-second-episode.Rmd")
  expect_equal(h1, h2, ignore_attr = TRUE)
})

test_that("HTML files are present and have the correct elements", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
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
})

test_that("files will not be rebuilt unless they change in content", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # expect_silent(suppressMessages(build_lesson(tmp, preview = FALSE)))
  suppressMessages({
    expect_failure({
      expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE), 
      "ordinary text without R code")
    })
  })

  fs::file_touch(fs::path(tmp, "episodes", "01-introduction.Rmd"))

  # expect_silent(suppressMessages(build_lesson(tmp, preview = FALSE)))
  suppressMessages({
    expect_failure({
      expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE), 
      "ordinary text without R code")
    })
  })

  expect_true(fs::file_exists(fs::path(sitepath, "01-introduction.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "02-second-episode.html")))

})

test_that("if index.md exists, it will be used for the home page", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  writeLines("I am an INDEX\n", fs::path(tmp, "index.md"))
  build_lesson(tmp, quiet = TRUE, preview = FALSE)

  expect_true(any(grepl(
        "I am an INDEX",
        readLines(fs::path(sitepath, "index.html"))
  )))

})


test_that("episodes with HTML in the title are rendered correctly", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  se <- readLines(fs::path(tmp, "episodes", "02-second-episode.Rmd"))
  se[[2]] <- "title: A **bold** title"
  writeLines(se, fs::path(tmp, "episodes", "02-second-episode.Rmd"))

  suppressMessages({
    expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE), "ordinary text without R code")
  })

  h1 <- expect_hashed(tmp, "01-introduction.Rmd")
  h2 <- expect_hashed(tmp, "02-second-episode.Rmd")
  expect_failure(expect_equal(h1, h2, ignore_attr = TRUE))
  expect_true(fs::file_exists(fs::path(sitepath, "02-second-episode.html")))

  expect_true(any(grepl(
        "A <strong>bold</strong> title", 
        readLines(fs::path(sitepath, "02-second-episode.html")),
        fixed = TRUE
  )))
})
