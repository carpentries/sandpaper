test_that("lessons can be created in empty directories", {

  tmpdir <- fs::file_temp()
  tmp    <- fs::path(tmpdir, "lesson-example")

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
  expect_match(readLines(fs::path(tmp, "README.md")), "lesson-example", fixed = TRUE) 
  expect_true(fs::file_exists(fs::path(tmp, "site/README.md")))
  expect_true(fs::file_exists(fs::path(tmp, ".gitignore")))
  
  # Ensure it is a git repo
  expect_true(fs::dir_exists(fs::path(tmp, ".git")))

  commits <- gert::git_log(repo = tmp)
  config <- gert::git_config(repo = tmp)

  expect_equal(nrow(commits), 1L)
  expect_match(commits$message[1L], "Initial commit")

  if (gert::user_is_configured()) {
    expect_match(commits$author[1L], config$value[config$name == "user.name"], fixed = TRUE)
  } else {
    expect_match(commits$author[1L], "carpenter <team@carpentries.org>", fixed = TRUE)
  }

  # Temporary configurations are not permanent
  if (gert::user_is_configured()) {
    expect_false(config$value[config$name == "user.name"] == "carpenter")
    expect_false(config$value[config$name == "user.email"] == "team@carpentries.org")
  } else {
    expect_false(length(config$value[config$name == "user.name"]) > 0)
    expect_false(length(config$value[config$name == "user.email"]) > 0)
  }

})

test_that("lessons cannot be created in directories that are occupied", {

  tmpdir <- fs::file_temp()
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # Make sure everything exists
  expect_true(fs::dir_exists(tmp))

  # This should fail
  expect_error(create_lesson(tmp), "lesson-example is not an empty directory.")

})
