res <- restore_fixture()


test_that("get_child_files() will return an empty list for lessons with no child files", {
  lsn <- this_lesson(res)
  expected <- list(a = NULL)
  expected <- expected[lengths(expected) > 0]
  expect_type(get_child_files(lsn), "list")
  expect_equal(get_child_files(lsn), expected)
})


test_that("the build database will record new entries", {

  outdir <- path_built(res)
  db_path <- fs::path(outdir, "md5sum.txt")
  # database should not exist
  expect_false(fs::file_exists(db_path))

  # the table starts out empty
  db <- get_built_db(db_path)
  expect_s3_class(db, "data.frame")
  expect_equal(nrow(db), 0L)
  expect_named(db, c("file", "checksum", "built"))

  sources <- get_build_sources(res, outdir, slug = NULL, quiet = TRUE)
  stat <- build_status(sources, db_path, rebuild = FALSE, write = TRUE)

  # the database now exists
  expect_true(fs::file_exists(db_path))

  # the output of the build status is a list with files to build and the
  # database of changed files
  expect_type(stat, "list")
  expect_named(stat, c("build", "new"))
  expect_type(stat$build, "character")
  expect_s3_class(stat$new, "data.frame")
  expect_named(stat$new, c("file", "checksum", "built", "date"))


  # get the episode from the sources
  db <- get_built_db(db_path, "Rmd")
  expect_s3_class(db, "data.frame")
  expect_equal(nrow(db), 1L)
  expect_named(db, c("file", "checksum", "built", "date"))
  md5 <- unname(tools::md5sum(fs::path(res, db$file)))
  expect_equal(md5, db$checksum)
  expect_true(md5 %in% stat$new$checksum)

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






