test_that("null pipe works", {
  expect_equal(letters %||% LETTERS, letters)
  expect_equal(NULL %||% LETTERS, LETTERS)
  expect_equal(NA_character_ %||% LETTERS, NA_character_)
})



test_that("example docs can run in a safe environment", {

  skip_on_cran()
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  skip_if_not(has_git())
  skip_if_not_installed("withr")

  expect_true(example_can_run())

})

test_that("copy assets will fail gracefully", {


  skip("I have no clue why this is only working some of the time :weary:")
  tmpdir <- fs::file_temp()
  withr::defer(fs::dir_delete(c(tmpdir)))
  fs::dir_create(tmpdir)
  expect_message(copy_assets(getOption("sandpaper.test_fixture"), tmpdir),
    "There was an issue copying")

})

test_that("a sitemap can be generated for urls", {
  urls <- c("https://example.com/one", "https://example.com/two")
  expect_snapshot(urls_to_sitemap(urls))
})
