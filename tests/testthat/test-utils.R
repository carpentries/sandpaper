test_that("null pipe works", {
  expect_equal(letters %||% LETTERS, letters)
  expect_equal(NULL %||% LETTERS, LETTERS)
  expect_equal(NA_character_ %||% LETTERS, NA_character_)
})


test_that("copy assets will fail gracefully", {

  tmpdir <- fs::file_temp()
  withr::defer(fs::dir_delete(c(tmpdir)))
  fs::dir_create(tmpdir)
  expect_message(copy_assets(getOption("sandpaper.test_fixture"), tmpdir), 
    "There was an issue copying")

})
