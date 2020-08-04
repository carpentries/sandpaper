test_that("lessons can be created in empty directories", {

  tmp <- fs::file_temp(ext = "/lesson-test")
  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # Make sure everything exists
  expect_true(fs::dir_exists(tmp))
  expect_true(fs::dir_exists(fs::path(tmp, "site")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "data")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "files")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "figures")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "extras")))
  expect_true(fs::file_exists(fs::path(tmp, "README.md")))
  expect_true(fs::file_exists(fs::path(tmp, "site/README.md")))
  expect_true(fs::file_exists(fs::path(tmp, ".gitignore")))
  
  # Ensure it is a git repo
  expect_true(fs::dir_exists(fs::path(tmp, ".git")))
  commits <- gert::git_log(repo = tmp)
  expect_equal(nrow(commits), 1L)
  expect_match(commits$message[1L], "Initial commit")

})

test_that("lessons cannot be created in directories that are occupied", {

  tmp <- fs::file_temp(ext = "/lesson-test")
  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # Make sure everything exists
  expect_true(fs::dir_exists(tmp))

  # This should fail
  expect_error(create_lesson(tmp), "lesson-test is not an empty directory.")

})
