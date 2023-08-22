
test_that("We can switch between overview and regular lesson metadata", {
  lsn <- restore_fixture()
  # CONTEXT ---------------------------------------------------
  # I discovered that if I had built a _regular_ lesson after an overview lesson
  # then the regular lesson accidentally inherited some metadata from the
  # overview lesson. This extended to fields like overview and url, so I am
  # explicitly checking these, but it does point at a bigger question.
  # END CONTEXT -----------------------------------------------
  # make a duplicate of this lesson
  tmp <- withr::local_tempfile()
  fs::dir_copy(lsn, tmp)
  this_metadata$clear()
  clear_this_lesson()
  withr::defer({
    this_metadata$clear()
    clear_this_lesson()
  })

  # check lesson defaults and norms ---------------------------
  lcfg <- get_config(lsn)
  expect_null(lcfg$overview)
  expect_null(lcfg$url)

  # when we register the global variables for the lesson, they should NOT match
  # the overview
  less <- this_lesson(lsn)
  lmeta <- this_metadata$get()
  expect_type(lmeta, "list")
  expect_false(less$overview)
  expect_false(lmeta$overview)
  expect_match(lmeta$url, "/lesson-example/", fixed = TRUE)

  # setup overview lesson -------------------------------------
  # remove first episode
  reset_episodes(tmp)
  # add overview to config
  suppressMessages({
    set_config(list(overview = TRUE, url = "https://example.com/"),
      path = tmp, create = TRUE, write = TRUE)
  })
  # delete episodes folder
  fs::dir_delete(fs::path(tmp, "episodes"))

  expect_false(fs::dir_exists(fs::path(tmp, "episodes")))
  expect_false(fs::dir_exists(fs::path(tmp, "site", "docs")))

  ocfg <- get_config(tmp)
  expect_true(ocfg$overview)
  expect_equal(ocfg$url, "https://example.com/")

  # when we register the global variables for the overview, they should match
  # what is in our config
  over <- this_lesson(tmp)
  ometa <- this_metadata$get()
  expect_type(ometa, "list")
  expect_true(over$overview)
  expect_true(ometa$overview)
  expect_equal(ometa$url, "https://example.com/")

  # retest lesson to make sure the variables are reset
  less <- this_lesson(lsn)
  lmeta <- this_metadata$get()
  expect_type(ometa, "list")
  expect_false(less$overview)
  expect_false(lmeta$overview)
  expect_match(lmeta$url, "/lesson-example/", fixed = TRUE)

})

test_that("Lessons without episodes can be built", {
  lsn <- restore_fixture()

  # remove first episode
  sandpaper::reset_episodes(lsn)
  # add overview to config
  suppressMessages({
    set_config(list(overview = TRUE, url = "https://example.com/"),
      path = tmp, create = TRUE, write = TRUE)
  })
  # delete episodes folder
  fs::dir_delete(fs::path(lsn, "episodes"))

  expect_false(fs::dir_exists(fs::path(lsn, "episodes")))
  expect_false(fs::dir_exists(fs::path(lsn, "site", "docs")))
  expect_true(get_config(lsn)$overview)


  withr::local_options(list("sandpaper.use_renv" = FALSE))
  sandpaper::build_lesson(lsn, quiet = TRUE, preview = FALSE)

  expect_true(fs::dir_exists(fs::path(lsn, "site", "built")))
  expect_true(fs::dir_exists(fs::path(lsn, "site", "docs")))

  # read in index and make sure the destinations are correct
  idx_file <- fs::path(lsn, "site", "docs", "index.html")
  expect_true(fs::file_exists(idx_file))
  idx <- xml2::read_html(idx_file)
  edit_link <- xml2::xml_find_first(idx, ".//a[text()='Edit on GitHub']")
  expect_match(xml2::xml_attr(edit_link, "href"), "edit/main/index.md")

})


test_that("top level fig, files, and data directories are copied over", {

  lsn <- restore_fixture()

  # remove first episode
  sandpaper::reset_episodes(lsn)
  # add overview to config
  suppressMessages({
    set_config(list(overview = TRUE, url = "https://example.com/"),
      path = tmp, create = TRUE, write = TRUE)
  })
  # delete episodes folder
  fs::dir_delete(fs::path(lsn, "episodes"))

  expect_false(fs::dir_exists(fs::path(lsn, "episodes")))
  expect_false(fs::dir_exists(fs::path(lsn, "site", "docs")))
  expect_true(get_config(lsn)$overview)


  fs::dir_create(fs::path(lsn, c("fig", "files", "data")))
  fs::file_touch(fs::path(lsn, c("fig", "files", "data"), "hello.png"))

  withr::local_options(list("sandpaper.use_renv" = FALSE))
  sandpaper::build_lesson(lsn, quiet = TRUE, preview = FALSE)

  expect_true(fs::dir_exists(fs::path(lsn, "site", "docs", "fig")))
  expect_true(fs::dir_exists(fs::path(lsn, "site", "docs", "files")))
  expect_true(fs::dir_exists(fs::path(lsn, "site", "docs", "data")))

  expect_true(fs::file_exists(fs::path(lsn, "site", "docs", "fig", "hello.png")))
  expect_true(fs::file_exists(fs::path(lsn, "site", "docs", "files", "hello.png")))
  expect_true(fs::file_exists(fs::path(lsn, "site", "docs", "data", "hello.png")))
})



