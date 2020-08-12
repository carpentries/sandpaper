test_that("markdown vignettes can be built without fail", {
  
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)
  create_episode("second-episode", path = tmp)
  expect_equivalent(res, tmp)

  # It's noisy at first
  expect_output(build_markdown_vignettes(res), "ordinary text without R code")

  # see helper-hash.R
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_equivalent(h1, h2)

  # But will not built if things are not changed
  expect_silent(build_markdown_vignettes(res))
  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))
  expect_silent(build_markdown_vignettes(res))

})
