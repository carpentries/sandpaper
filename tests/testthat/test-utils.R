test_that("null pipe works", {
  expect_equal(letters %||% LETTERS, letters)
  expect_equal(NULL %||% LETTERS, LETTERS)
  expect_equal(NA_character_ %||% LETTERS, NA_character_)
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
