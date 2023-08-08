res <- restore_fixture()


test_that("root path will find the root of the lesson locally", {

  here  <- as.character(res)
  expect_identical(root_path(here), here)

  there <- fs::path(res, "episodes")
  expect_identical(root_path(there), here)

  there <- fs::path(res, "learners", "setup.md")
  expect_identical(root_path(there), here)

  # if we insert a config.yaml file into the built folder, it will not cause a
  # problem
  there <- fs::path(res, "site", "built")
  fs::file_copy(fs::path(res, "config.yaml"), there)
  expect_identical(root_path(there), here)

  # removing the episodes folder does not invalidate the lesson
  fs::dir_delete(fs::path(here, "episodes"))
  expect_identical(root_path(there), here)

})

