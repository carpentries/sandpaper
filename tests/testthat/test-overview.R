lsn <- restore_fixture()


test_that("Lessons without episodes can be built", {
  # remove first episode
  sandpaper::reset_episodes(lsn)
  # add overview to config
  cat("\noverview: true\n", file = fs::path(lsn, "config.yaml"), append = TRUE)
  # delete episodes folder
  fs::dir_delete(fs::path(lsn, "episodes"))
  fs::dir_delete(fs::path(lsn, "renv"))

  expect_false(fs::dir_exists(fs::path(lsn, "episodes")))
  expect_false(fs::dir_exists(fs::path(lsn, "site", "docs")))
  expect_true(get_config(lsn)$overview)


  withr::local_options(list("sandpaper.use_renv" = FALSE))
  sandpaper::build_lesson(lsn, quiet = TRUE, preview = FALSE)

  expect_true(fs::dir_exists(fs::path(lsn, "site", "built")))
  expect_true(fs::dir_exists(fs::path(lsn, "site", "docs")))

})


