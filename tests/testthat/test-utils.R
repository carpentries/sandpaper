test_that("null pipe works", {
  expect_equal(letters %||% LETTERS, letters)
  expect_equal(NULL %||% LETTERS, LETTERS)
  expect_equal(NA_character_ %||% LETTERS, NA_character_)
})
