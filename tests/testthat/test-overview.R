lsn <- restore_fixture()

test_that("Lessons without episodes can be built", {
  # remove first episode
  sandpaper::reset_episodes(lsn)
  # add overview to config
  cat("\noverview: true\n", file = fs::path(lsn, "config.yaml"), append = TRUE)
  # delete episodes folder
  fs::dir_delete(fs::path(lsn, "episodes"))

  expect_false(fs::dir_exists(fs::path(lsn, "episodes")))
  expect_false(fs::dir_exists(fs::path(lsn, "site", "docs")))
  expect_true(get_config(lsn)$overview)


  withr::local_options(list("sandpaper.use_renv" = FALSE))
  sandpaper::build_lesson(lsn, quiet = TRUE, preview = FALSE)

  expect_true(fs::dir_exists(fs::path(lsn, "site", "built")))
  expect_true(fs::dir_exists(fs::path(lsn, "site", "docs")))

})



test_that("top level fig, files, and data directories are copied over", {

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



