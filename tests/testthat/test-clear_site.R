tmp <- res <- restore_fixture()
suppressMessages(s <- get_episodes(tmp))
set_episodes(tmp, s, write = TRUE)

test_that("the site can be cleared", {

  # Make sure everything exists
  expect_true(check_lesson(tmp))

  expected <- c("DESCRIPTION", "README.md", "_pkgdown.yaml", "built")
  clean_site <- fs::dir_ls(fs::path(tmp, "site"))
  expect_length(clean_site, 4)
  expect_setequal(clean_site, fs::path(tmp, "site", expected))

  # I can save a file in the episodes directory and it will be propogated 
  saveRDS(expected, file = fs::path(tmp, "episodes", "data", "test.rds"))

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  build_lesson(tmp, preview = FALSE, quiet = TRUE)

  built_site <- fs::dir_ls(fs::path(tmp, "site"))
  expect_length(built_site, 5)
  expect_setequal(built_site, fs::path(tmp, "site", c(expected, "docs")))

  rds <- fs::path(tmp, "site", "built", "data", "test.rds")
  # must do two tests here for windows to pass since it does not possess a lockfile
  built_files <- length(fs::dir_ls(fs::path(tmp, "site", "built")))
  expect_gte(built_files, 13L)
  expect_lte(built_files, 14L)
  expect_true(fs::file_exists(rds))
  expect_equal(readRDS(rds), expected)

  reset_site(tmp)

  expect_length(fs::dir_ls(fs::path(tmp, "site")), 4L)
  expect_length(fs::dir_ls(fs::path(tmp, "site", "built")), 0L)

})
