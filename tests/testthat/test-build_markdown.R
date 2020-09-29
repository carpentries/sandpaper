test_that("markdown sources can be built without fail", {
  
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)
  create_episode("second-episode", path = tmp)
  expect_warning(s <- get_schedule(tmp), "set_schedule")
  set_schedule(tmp, s, write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)

  # It's noisy at first
  suppressMessages({
  expect_output(build_markdown(res, quiet = FALSE), "ordinary text without R code")
  })

  # see helper-hash.R
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_equal(h1, h2, ignore_attr = TRUE)

  # Output is not commented
  built  <- get_built_files(res)
  ep     <- trimws(readLines(built[[1]]))
  ep     <- ep[ep != ""]
  outid  <- grep("[1]", ep, fixed = TRUE)
  output <- ep[outid[1]]
  fence  <- ep[outid[1] - 1]
  expect_match(output, "^\\[1\\]")
  expect_match(fence, "^[`]{3}[{]\\.output[}]")

  # But will not built if things are not changed
  expect_silent(build_markdown(res))
  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))
  expect_silent(build_markdown(res))

})
