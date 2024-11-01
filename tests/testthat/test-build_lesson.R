
tmp <- res <- restore_fixture()
metadata_json <- trimws(create_metadata_jsonld(tmp))
sitepath <- fs::path(tmp, "site", "docs")


test_that("Lessons built for the first time are noisy", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # It's noisy at first
  suppressMessages({
    expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE),
      processing_("introduction.Rmd")) # chunk name from example episode
  })
  htmls <- read_all_html(sitepath)
  expect_setequal(names(htmls$learner),
    c("introduction", "index", "LICENSE", "CODE_OF_CONDUCT", "profiles",
      "instructor-notes", "key-points", "aio", "images", "reference", "404")
  )
  expect_setequal(names(htmls$instructor),
    c("introduction", "index", "LICENSE", "CODE_OF_CONDUCT", "profiles",
      "instructor-notes", "key-points", "aio", "images", "reference", "404")
  )

})


htmls <- NULL
if (rmarkdown::pandoc_available("2.11")) {
  htmls <- read_all_html(sitepath)
}

pkg <- pkgdown::as_pkgdown(fs::path_dir(sitepath))


test_that("The lesson contact is always team@carpentries.org", {
  dsc <- desc::description$new(sub("docs[/]?", "DESCRIPTION", sitepath))
  auth <- eval(parse(text = dsc$get_field("Authors@R")))
  expect_equal(as.character(auth),
    "Jo Carpenter <team@carpentries.org> [aut, cre]")
})


test_that("build_lesson() also builds the extra pages", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_true(fs::dir_exists(sitepath))
  expect_true(fs::file_exists(fs::path(sitepath, "404.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "404.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor-notes.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "instructor-notes.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "key-points.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "key-points.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "aio.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "aio.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "images.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "instructor", "images.html")))
})



test_that("local site build produces 404 page with relative links", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # in the site branch, it does exist
  expect_true(file.exists(file.path(sitepath, "404.html")))
  # parse the page to find the stylesheet node
  html <- xml2::read_html(file.path(sitepath, "404.html"))
  stysh <- xml2::xml_find_first(html, ".//head/link[@rel='stylesheet']")
  url <- xml2::xml_attr(stysh, "href")
  parsed <- xml2::url_parse(url)

  # test that it does not hav the form of
  # https://[server]/lesson-example/[stylesheet]
  expect_equal(parsed[["scheme"]], "")
  expect_equal(parsed[["server"]], "")
  expect_false(startsWith(parsed[["path"]], "/lesson-example"))
})


# test_that("Anchors for Keypoints are not missing", {
#   skip_if_not(rmarkdown::pandoc_available("2.11"))
#   html <- xml2::read_html(fs::path(sitepath, "introduction.html"))
#   anchor <- xml2::xml_find_first(html, ".//div[contains(@class, 'keypoints')]//h3/a")
#   expect_match(xml2::xml_attr(anchor, "href"), "[#]keypoints")
#   expect_match(xml2::xml_attr(anchor, "class"), "anchor")
#   expect_match(xml2::xml_attr(anchor, "aria-label"), "anchor")
# })


test_that("aio page can be rebuilt", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  aio <- fs::path(sitepath, "aio.html")
  iaio <- fs::path(sitepath, "instructor/aio.html")
  expect_true(fs::file_exists(aio))
  expect_true(fs::file_exists(iaio))
  html <- xml2::read_html(aio)
  content <- get_content(html, "section[starts-with(@id, 'aio-')]")
  expect_length(content, 1L)
  expect_equal(xml2::xml_attr(content, "id"), "aio-introduction")

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
  expect_equal(xml2::xml_attr(content, "id"), "introduction")

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
  expect_equal(xml2::xml_attr(content, "id"), "introduction")
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

test_that("empty instructor notes build", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # 0. Test that the placeholder text exists in the rendered instructor notes
  build_instructor_notes(pkg, pages = htmls, quiet = TRUE)
  expect_true(any(grepl(
    "This is a placeholder file.",
    readLines(fs::path(sitepath, "instructor-notes.html"))
  )))
  # 1. make a copy of the instructor-notes.md to a local tempfile (use tmp <-
  # withr::local_tempfile() and fs::file_copy()
  tmp <- withr::local_tempfile()
  fs::file_copy(fs::path(res, "instructors/instructor-notes.md"), tmp)
  # 2. use withr::defer() to do the opposite, copying over the saved file back
  # when the test finishes)
  withr::defer({
    fs::file_copy(tmp, fs::path(res, "instructors/instructor-notes.md"), overwrite = TRUE)
  }, priority = "first")
  # 3. replace the instructor-notes.md with "---\ntitle: test\n---\n" using the
  # writeLines() function
  writeLines("---\ntitle: test\n---\n", fs::path(res, "instructors/instructor-notes.md"))
  # 4. test that build_instructor_notes() builds the notes and doesn't throw an
  # error.
  expect_no_error(build_instructor_notes(pkg, pages = htmls, quiet = TRUE))
  # 5. test for the absence of placeholder text
  expect_false(any(grepl(
    "This is a placeholder file.",
    readLines(fs::path(sitepath, "instructor-notes.html"))
  )))
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
  suppressMessages({
    create_episode("_Second_ Episode!", path = tmp, open = FALSE)
    s <- get_episodes(tmp)
  })
  set_episodes(tmp, s, write = TRUE)

  rdr <- sandpaper_site(fs::path(tmp, "episodes", "second-episode.Rmd"))
  expect_named(rdr, c("name", "output_dir", "render", "clean", "subdirs"))

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  suppressMessages({
    rdr$render() %>%
      expect_output(processing_("second-episode.Rmd")) %>%
      expect_message("Output created: .*second-episode.html")
  })

})


test_that("Individual files contain matching metadata", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  idx <- xml2::read_html(fs::path(path_site(tmp), "docs", "second-episode.html"))

  actual <- xml2::xml_find_first(idx, ".//script[@type='application/ld+json']")
  actual <- trimws(xml2::xml_text(actual))
  expect_match(actual, '"name": "Second Episode!"')
  expect_match(actual, "second-episode.html")
})

test_that("single files can be re-built", {

  skip_on_os("windows")
  expect_hashed(tmp, "second-episode.Rmd")
  rdr <- sandpaper_site(fs::path(tmp, "episodes", "second-episode.Rmd"))
  expect_named(rdr, c("name", "output_dir", "render", "clean", "subdirs"))

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  suppressMessages({
    rdr$render() %>%
      expect_output(processing_("second-episode.Rmd")) %>%
      expect_message("Output created: .*second-episode.html")
  })

  suppressMessages({
    rdr$render(fs::path(tmp, "LICENSE.md")) %>%
      expect_message("Writing") %>%
      expect_message("Output created: .*LICENSE.html")
  })

})


test_that("source files are hashed", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # see helper-hash.R
  h1 <- expect_hashed(tmp, "introduction.Rmd")
  h2 <- expect_hashed(tmp, "second-episode.Rmd")
  # the hashes will no longer be equal because the titles are now different
  expect_failure(expect_equal(h1, h2, ignore_attr = TRUE))

})

test_that("HTML files are present and have the correct elements", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_true(fs::file_exists(fs::path(sitepath, "introduction.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "second-episode.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "index.html")))
  ep <- readLines(fs::path(sitepath, "introduction.html"))

  # Div tags show up as expected
  expect_true(any(grepl(".div.+? class..callout challenge", ep)))
  # figure captions show up from knitr
  # (https://github.com/carpentries/sandpaper/issues/114)
  expect_true(any(grepl("Sun arise each and every morning", ep)))
  expect_true(any(grepl(
        ".div.+? class..callout challenge",
        readLines(fs::path(sitepath, "second-episode.html"))
  )))
  expect_true(any(grepl(
        "second-episode.html",
        readLines(fs::path(sitepath, "index.html"))
  )))
})


test_that("Active episode contains sidebar number", {
  ep <- readLines(fs::path(sitepath, "second-episode.html"))
  xml <- xml2::read_html(paste(ep, collapse = ""))

  # Instructor sidebar is formatted properly
  sidebar <- xml2::xml_find_all(xml, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  this_ep <- xml2::xml_find_first(sidebar, ".//span[@class='current-chapter']")
  this_title <- as.character(xml2::xml_contents(this_ep))
  this_title <- trimws(paste(this_title, collapse = ""))
  expect_equal(this_title, "2. <em>Second</em> Episode!")
})


test_that("files will not be rebuilt unless they change in content", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  suppressMessages({
    expect_failure({
      expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE),
      processing_("second-episode.Rmd"))
    })
  })

  fs::file_touch(fs::path(tmp, "episodes", "introduction.Rmd"))

  suppressMessages({
    expect_failure({
      expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE),
      processing_("introduction.Rmd"))
    })
  })

  expect_true(fs::file_exists(fs::path(sitepath, "introduction.html")))
  expect_true(fs::file_exists(fs::path(sitepath, "second-episode.html")))

})

test_that("keypoints learner and instructor views are identical", {

  pkg <- pkgdown::as_pkgdown(fs::path(tmp, "site"))
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  instruct <- fs::path(pkg$dst_path, "instructor", "key-points.html")
  instruct <- xml2::read_html(instruct)
  learn <- fs::path(pkg$dst_path, "key-points.html")
  learn <- xml2::read_html(learn)

  # Instructor sidebar is formatted properly
  sidebar <- xml2::xml_find_all(instruct, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks_instructor <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_snapshot(writeLines(sidelinks_instructor))

  # Learner sidebar is formatted properly
  sidebar <- xml2::xml_find_all(learn, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks_learner <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_snapshot(writeLines(sidelinks_learner))

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
    c("aio-introduction", "aio-second-episode"))

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

  se <- readLines(fs::path(tmp, "episodes", "second-episode.Rmd"))
  se[[2]] <- "title: A **bold** title"
  writeLines(se, fs::path(tmp, "episodes", "second-episode.Rmd"))

  suppressMessages({
    expect_output(build_lesson(tmp, preview = FALSE, quiet = FALSE),
      processing_("second-episode.Rmd"))
  })

  h1 <- expect_hashed(tmp, "introduction.Rmd")
  h2 <- expect_hashed(tmp, "second-episode.Rmd")
  expect_failure(expect_equal(h1, h2, ignore_attr = TRUE))
  expect_true(fs::file_exists(fs::path(sitepath, "second-episode.html")))

  expect_true(any(grepl(
        "A <strong>bold</strong> title",
        readLines(fs::path(sitepath, "second-episode.html")),
        fixed = TRUE
  )))
})
