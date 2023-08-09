res <- restore_fixture()


test_that("root path will find the root of the lesson locally", {

  here  <- fs::path_file(as.character(res))

  expect_identical(fs::path_file(root_path(res)), here)


  there <- fs::path(res, "episodes")
  expect_identical(fs::path_file(root_path(there)), here)

  there <- fs::path(res, "learners", "setup.md")
  expect_identical(fs::path_file(root_path(there)), here)

  # if we insert a config.yaml file into the built folder, it will not cause a
  # problem
  there <- fs::path(res, "site", "built")
  fs::file_copy(fs::path(res, "config.yaml"), there)
  expect_identical(fs::path_file(root_path(there)), here)

  # removing the episodes folder does not invalidate the lesson
  fs::dir_delete(fs::path(res, "episodes"))
  expect_identical(fs::path_file(root_path(there)), here)

})

