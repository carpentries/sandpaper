
tmp <- res <- restore_fixture()
metadata_json <- trimws(create_metadata_jsonld(tmp))
sitepath <- fs::path(tmp, "site", "docs")


test_that("Lessons built for the first time are noisy", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # It's noisy at first
  suppressMessages({
    expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE), 
      "ordinary text without R code")
  })

})

test_that("sitemap exists", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  sitemap <- fs::path(sitepath, "sitemap.xml")
  expect_true(fs::file_exists(sitemap))
  expect_equal(xml2::xml_name(xml2::read_xml(sitemap)), "urlset")
})


test_that("Metadata is recorded as the correct type", {
  expect_match(metadata_json, "\"@type\": \"TrainingMaterial\"", fixed = TRUE)
})

test_that("Lesson websites contains metadata", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  skip_on_os("windows")

  idx <- xml2::read_html(fs::path(path_site(tmp), "docs", "index.html"))

  actual <- xml2::xml_find_first(idx, ".//script[@type='application/ld+json']")
  actual <- trimws(xml2::xml_text(actual))

  expect_identical(actual, metadata_json)

})

test_that("Lesson websites contains instructor metadata", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  idx <- xml2::read_html(fs::path(path_site(tmp), "docs", "instructor", "index.html"))

  actual <- xml2::xml_find_first(idx, ".//script[@type='application/ld+json']")
  actual <- trimws(xml2::xml_text(actual))

  expect_match(actual, "[/]instructor")

})

test_that("single files can be built", {

  create_episode("second-episode", path = tmp)
  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)

  rdr <- sandpaper_site(fs::path(tmp, "episodes", "02-second-episode.Rmd"))
  expect_named(rdr, c("name", "output_dir", "render", "clean", "subdirs"))

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  suppressMessages({
    rdr$render() %>%
      expect_output("ordinary text without R code") %>%
      expect_message("Output created: .*02-second-episode.html")
  })

})


test_that("Individual files contain matching metadata", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  idx <- xml2::read_html(fs::path(path_site(tmp), "docs", "02-second-episode.html"))

  actual <- xml2::xml_find_first(idx, ".//script[@type='application/ld+json']")
  actual <- trimws(xml2::xml_text(actual))
  expect_match(actual, "Using RMarkdown")
  expect_match(actual, "02-second-episode.html")
})

test_that("single files can be re-built", {

  skip_on_os("windows")
  expect_hashed(tmp, "02-second-episode.Rmd")
  rdr <- sandpaper_site(fs::path(tmp, "episodes", "02-second-episode.Rmd"))
  expect_named(rdr, c("name", "output_dir", "render", "clean", "subdirs"))

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  suppressMessages({
    rdr$render() %>%
      expect_output("ordinary text without R code") %>%
      expect_message("Output created: .*02-second-episode.html")
  })

  suppressMessages({
    rdr$render(fs::path(tmp, "LICENSE.md")) %>%
      expect_output("Writing") %>%
      expect_message("Output created: .*LICENSE.html")
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
  expect_true(any(grepl(".div.+? class..callout challenge", ep)))
  # figure captions show up from knitr 
  # (https://github.com/carpentries/sandpaper/issues/114) 
  expect_true(any(grepl("Sun arise each and every morning", ep)))
  expect_true(any(grepl(
        ".div.+? class..callout challenge", 
        readLines(fs::path(sitepath, "02-second-episode.html"))
  )))
  expect_true(any(grepl(
        "02-second-episode.html",
        readLines(fs::path(sitepath, "index.html"))
  )))
})

test_that("files will not be rebuilt unless they change in content", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  suppressMessages({
    expect_failure({
      expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE), 
      "ordinary text without R code")
    })
  })

  fs::file_touch(fs::path(tmp, "episodes", "01-introduction.Rmd"))

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
