test_that("markdown vignettes can be built without fail", {
  
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # It's noisy at first
  expect_output(build_markdown_vignettes(res), "ordinary text without R code")

  expected_hash <- tools::md5sum(fs::path(res, "episodes", "01-introduction.Rmd"))
  actual_hash   <- get_hash(fs::path(res, "site", "vignettes", "01-introduction.Rmd"))
  expect_equivalent(expected_hash, actual_hash)

  # But will not built if things are not changed
  expect_silent(build_markdown_vignettes(res))
  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))
  expect_silent(build_markdown_vignettes(res))

})
