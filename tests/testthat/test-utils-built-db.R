res <- restore_fixture()


test_that("get_child_files() will return an empty list for lessons with no child files", {
  lsn <- this_lesson(res)
  expected <- list(a = NULL)
  expected <- expected[lengths(expected) > 0]
  expect_type(get_child_files(lsn), "list")
  expect_equal(get_child_files(lsn), expected)
})


test_that("get_child_files() will return a list of files that have child documents in lessons", {
  # we will copy over an episode "child-haver.Rmd", that will have a child
  # called "files/figures.md"
  fs::file_copy(test_path("examples", "child-haver.Rmd"),
    fs::path(res, "episodes", "child-haver.Rmd"))
  fs::file_copy(test_path("examples", "figures.md"),
    fs::path(res, "episodes", "files", "figures.md"))
  move_episode("child-haver.Rmd", 2, path = res, write = TRUE)

  lsn <- this_lesson(res)
  expected <- list("child-haver.Rmd" = c("files/figures.md"))
  expect_type(get_child_files(lsn), "list")
  expect_equal(get_child_files(lsn), expected)
})


