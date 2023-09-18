test_that("read_all_html returns appropriate files", {
  tmpdir <- withr::local_tempdir()
  fs::dir_create(tmpdir)
  fs::dir_create(fs::path(tmpdir, "instructor"))
  writeLines("<p>Instructor</p>", fs::path(tmpdir, "instructor", "index.html"))
  writeLines("<p>Learner</p>", fs::path(tmpdir, "index.html"))
  res <- read_all_html(tmpdir)
  expect_named(res, c("instructor", "learner", "paths"))
  expect_length(res$paths, 2L)
  expect_s3_class(res$learner$index, "xml_document")
  expect_s3_class(res$instructor$index, "xml_document")
  expect_equal(xml2::xml_text(res$learner$index), "Learner")
  expect_equal(xml2::xml_text(res$instructor$index), "Instructor")
})

test_that("escape ampersand works as promised", {
  expected <- "Hall &amp; Oates"
  expect_equal(escape_ampersand("Hall & Oates"), expected)
})


test_that("aggregate pages do not exorcise self-similar slugs", {
  # see https://github.com/carpentries/sandpaper/issues/511
  #
  # If we set up tests with episodes whose names also match the slugs for
  # the builders, then we can effectively test that they will work as expected
  # if we query the aggregate pages for links back to the original episodes
  res <- restore_fixture()
  withr::local_options(list("sandpaper.use_renv" = FALSE))
  withr::defer(clear_globals())
  create_episode_md("images and pixels", path = res, add = TRUE)
  create_episode_md("keypoints and others", path = res, add = TRUE)
  create_episode_md("instructor notes and things", path = res, add = TRUE)
  create_episode_md("aio stands for an information overload", path = res, add = TRUE)
  eps <- as.character(fs::path_ext_set(get_episodes(res), "html"))
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  build_lesson(res, quiet = TRUE, preview = FALSE)
  sitepath <- fs::path(res, "site/docs")

  # build_images() -----------------------------------------------
  images <- fs::path(sitepath, "images.html")
  instruct_images <- fs::path(sitepath, "instructor/images.html")
  expect_true(fs::file_exists(images))
  expect_true(fs::file_exists(instruct_images))
  html <- xml2::read_html(images)

  # ensure the section titles work
  sections <- get_content(html, "section")
  expect_length(sections, 5L)
  expect_equal(xml2::xml_attr(sections, "id"), get_slug(eps),
    label = "images"
  )

  # ensure the links are cromulent
  links <- get_content(html, "section/h2/a")
  expect_length(links, 5L)
  expect_equal(xml2::xml_attr(links, "href"), eps,
    label = "images"
  )

  # build_keypoints() -----------------------------------------------
  keypoints <- fs::path(sitepath, "key-points.html")
  instruct_keypoints <- fs::path(sitepath, "instructor/key-points.html")
  expect_true(fs::file_exists(keypoints))
  expect_true(fs::file_exists(instruct_keypoints))
  html <- xml2::read_html(keypoints)

  # ensure the section titles work
  sections <- get_content(html, "section")
  expect_length(sections, 5L)
  expect_equal(xml2::xml_attr(sections, "id"), get_slug(eps),
    label = "key-points"
  )

  # ensure the links are cromulent
  links <- get_content(html, "section/h2/a")
  expect_length(links, 5L)
  expect_equal(xml2::xml_attr(links, "href"), eps,
    label = "key-points"
  )

  # build_instructor_notes() -----------------------------------------------
  instructor_notes <- fs::path(sitepath, "instructor-notes.html")
  instruct_instructor_notes <- fs::path(sitepath, "instructor/instructor-notes.html")
  expect_true(fs::file_exists(instructor_notes))
  expect_true(fs::file_exists(instruct_instructor_notes))
  expect_length(get_content(xml2::read_html(instructor_notes), "section/*"), 0)
  html <- xml2::read_html(instruct_instructor_notes)

  # ensure the section titles work
  sections <- get_content(html, "section/*")
  expect_length(sections, 5L)
  expect_equal(xml2::xml_attr(sections, "id"), get_slug(eps),
    label = "instructor-notes"
  )

  # ensure the links are cromulent
  links <- get_content(html, "section/section/h2/a")
  expect_length(links, 5L)
  expect_equal(xml2::xml_attr(links, "href"), eps,
    label = "instructor-notes"
  )

  # build_aio() -----------------------------------------------
  aio <- fs::path(sitepath, "aio.html")
  instruct_aio <- fs::path(sitepath, "instructor/aio.html")
  expect_true(fs::file_exists(aio))
  expect_true(fs::file_exists(instruct_aio))
  html <- xml2::read_html(aio)

  # ensure the section titles work
  sections <- get_content(html, "section")
  expect_length(sections, 5L)
  # the AIO sections have slugs
  expect_equal(xml2::xml_attr(sections, "id"), paste0("aio-", get_slug(eps)),
    label = "aio"
  )

  # ensure the links are cromulent
  links <- get_content(html, "section/p[1]/a")
  expect_length(links, 5L)
  expect_equal(xml2::xml_attr(links, "href"), eps,
    label = "aio"
  )
})

