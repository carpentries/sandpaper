
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
  htmls <- read_all_html(sitepath)
  expect_setequal(names(htmls$learner), 
    c("01-introduction", "index", "LICENSE", "CODE_OF_CONDUCT", "profiles", 
      "instructor-notes", "key-points", "aio", "images")
  )
  expect_setequal(names(htmls$instructor), 
    c("01-introduction", "index", "LICENSE", "CODE_OF_CONDUCT", "profiles", 
      "instructor-notes", "key-points", "aio", "images")
  )

})


htmls <- NULL
if (rmarkdown::pandoc_available("2.11")) {
  htmls <- read_all_html(sitepath)
}

pkg <- pkgdown::as_pkgdown(fs::path_dir(sitepath))

test_that("build_lesson() also builds the extra pages", {
  expect_true(fs::dir_exists(sitepath))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor-notes.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "instructor-notes.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "key-points.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "key-points.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "aio.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "aio.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "images.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "images.html")))
})

test_that("aio page can be rebuilt", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  aio <- fs::path(sitepath, "aio.html")
  iaio <- fs::path(sitepath, "instructor/aio.html")
  expect_true(fs::file_exists(aio))
  expect_true(fs::file_exists(iaio))
  html <- xml2::read_html(aio)
  content <- get_content(html, "section[starts-with(@id, 'aio-')]")
  expect_length(content, 1L)
  expect_equal(xml2::xml_attr(content, "id"), "aio-01-introduction")

  # add an ephemeral section and write it out
  xml2::xml_add_sibling(content[[1]], "section", id = "ephemeral")
  writeLines(as.character(html), aio)
  content <- get_content(aio, "section[@id='ephemeral']", pkg = pkg)
  expect_length(content, 1L)
  
  # rebuild the content and check if the section still exists... it shouldn't
  build_aio(pkg, pages = htmls, quiet = TRUE)
  content <- get_content(aio, "section[@id='ephemeral']", pkg = pkg)
  expect_length(content, 0L)

})

test_that("keypoints page can be rebuilt", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  keypoints <- fs::path(sitepath, "key-points.html")
  ikeypoints <- fs::path(sitepath, "instructor/key-points.html")
  expect_true(fs::file_exists(keypoints))
  expect_true(fs::file_exists(ikeypoints))
  html <- xml2::read_html(keypoints)
  content <- get_content(html, "section")
  expect_length(content, 1L)
  expect_equal(xml2::xml_attr(content, "id"), "01-introduction")

  # add an ephemeral section and write it out
  xml2::xml_add_sibling(content[[1]], "section", id = "ephemeral")
  writeLines(as.character(html), keypoints)
  content <- get_content(keypoints, "section[@id='ephemeral']", pkg = pkg)
  expect_length(content, 1L)
  
  # rebuild the content and check if the section still exists... it shouldn't
  build_keypoints(pkg, pages = htmls, quiet = TRUE)
  content <- get_content(keypoints, "section[@id='ephemeral']", pkg = pkg)
  expect_length(content, 0L)

})

test_that("instructor-notes page can be rebuilt", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  notes <- fs::path(sitepath, "instructor-notes.html")
  inotes <- fs::path(sitepath, "instructor/instructor-notes.html")
  expect_true(fs::file_exists(notes))
  expect_true(fs::file_exists(inotes))
  html <- xml2::read_html(inotes)
  content <- get_content(html, "section[@id='aggregate-instructor-notes']/section")
  expect_length(content, 1L)
  expect_equal(xml2::xml_attr(content, "id"), "01-introduction")
  expect_match(xml2::xml_text(xml2::xml_find_first(content[[1]], ".//p")), 
    "Inline instructor notes")

  # add an ephemeral section and write it out
  xml2::xml_add_sibling(content[[1]], "section", id = "ephemeral")
  writeLines(as.character(html), inotes)
  content <- get_content(inotes, "/section[@id='ephemeral']", pkg = pkg, instructor = TRUE)
  expect_length(content, 1L)
  
  # rebuild the content and check if the section still exists... it shouldn't
  build_instructor_notes(pkg, pages = htmls, quiet = TRUE)
  content <- get_content(inotes, "/section[@id='ephemeral']", pkg = pkg, instructor = TRUE)
  expect_length(content, 0L)

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
  expect_match(actual, '"name": "second-episode"')
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
  # the hashes will no longer be equal because the titles are now different
  expect_failure(expect_equal(h1, h2, ignore_attr = TRUE))

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

test_that("keypoints learner and instructor views are identical", {

  pkg <- pkgdown::as_pkgdown(fs::path(tmp, "site"))
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  instruct <- fs::path(pkg$dst_path, "instructor", "key-points.html")
  instruct <- xml2::read_html(instruct)

  # Instructor sidebar is formatted properly
  sidebar <- xml2::xml_find_all(instruct, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_length(sidelinks, 6L)
  expect_match(sidelinks[[1]], "href=[\"]..[/]key-points.html")
  expect_match(sidelinks[[2]], "Summary and Schedule")

  learn <- fs::path(pkg$dst_path, "key-points.html")
  learn <- xml2::read_html(learn)
  
  # Learner sidebar is formatted properly
  sidebar <- xml2::xml_find_all(learn, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_match(sidelinks[[1]], "href=[\"]instructor[/]key-points.html")
  expect_match(sidelinks[[2]], "Summary and Setup")

  # sections are equal
  learn_sections <- as.character(xml2::xml_find_all(learn, ".//section"))
  instruct_sections <- as.character(xml2::xml_find_all(instruct, ".//section"))
  expect_equal(learn_sections, instruct_sections)

  # the instructor metadata contains this page information
  meta <- xml2::xml_find_first(instruct, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/instructor/key-points.html")

  # the learner metadata contains this page information
  meta <- xml2::xml_find_first(learn, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/key-points.html")
})


test_that("aio page is updated with new pages", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  aio <- fs::path(sitepath, "aio.html")
  iaio <- fs::path(sitepath, "instructor/aio.html")
  expect_true(fs::file_exists(aio))
  expect_true(fs::file_exists(iaio))
  html <- xml2::read_html(aio)
  content <- xml2::xml_find_all(html, 
    ".//div[contains(@class, 'lesson-content')]/section[starts-with(@id, 'aio-')]")
  expect_length(content, 2L)
  expect_equal(xml2::xml_attr(content, "id"), 
    c("aio-01-introduction", "aio-02-second-episode"))

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
