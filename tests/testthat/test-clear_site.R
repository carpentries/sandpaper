test_that("the site can be cleared", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # Make sure everything exists
  expect_true(check_lesson(tmp))

  expected <- c("DESCRIPTION", "README.md", "_pkgdown.yml", "vignettes")
  fs::dir_ls(fs::path(tmp, "site")) %>%
    expect_length(4) %>%
    expect_setequal(fs::path(tmp, "site", expected))

  invisible(capture.output(build_lesson(tmp, preview = FALSE, quiet = TRUE)))

  fs::dir_ls(fs::path(tmp, "site")) %>%
    expect_length(10)

})
