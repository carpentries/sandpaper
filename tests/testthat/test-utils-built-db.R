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
  withr::defer({
    if (fs::file_exists(db_path)) {
      fs::file_delete(db_path)
    }
  })

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


  # the resulting data is what we expect
  db <- get_built_db(db_path, "Rmd")
  expect_s3_class(db, "data.frame")
  expect_equal(nrow(db), 1L)
  expect_named(db, c("file", "checksum", "built", "date"))
  md5 <- unname(tools::md5sum(fs::path(res, db$file)))
  expect_equal(md5, db$checksum)
  expect_true(md5 %in% stat$new$checksum)
  expect_named(stat, c("build", "new"))
  expect_type(stat$build, "character")
  expect_s3_class(stat$new, "data.frame")
  expect_named(stat$new, c("file", "checksum", "built", "date"))


})


test_that("the build database will return no differences if no files change", {

  outdir <- path_built(res)
  db_path <- fs::path(outdir, "md5sum.txt")
  # database should not exist
  expect_false(fs::file_exists(db_path))
  withr::defer({
    if (fs::file_exists(db_path)) {
      fs::file_delete(db_path)
    }
  })

  # the table starts out empty
  db <- get_built_db(db_path)
  expect_s3_class(db, "data.frame")
  expect_equal(nrow(db), 0L)
  expect_named(db, c("file", "checksum", "built"))

  sources <- get_build_sources(res, outdir, slug = NULL, quiet = TRUE)
  stat <- build_status(sources, db_path, rebuild = FALSE, write = TRUE)

  expect_type(stat, "list")
  expect_named(stat, c("build", "new"))
  # the build stat will be all of the source files
  expect_type(stat$build, "character")
  expect_equal(fs::path_file(stat$build), fs::path_file(sources))
  expect_s3_class(stat$new, "data.frame")
  expect_named(stat$new, c("file", "checksum", "built", "date"))

  # a rerun returns a status where no files have changed.
  restat <- build_status(sources, db_path, rebuild = FALSE, write = TRUE)

  expect_type(restat, "list")
  expect_named(restat, c("build", "remove", "new", "old"))
  # no files are flagged for build or removal
  expect_type(restat$build, "character")
  expect_length(restat$build, 0L)
  expect_type(restat$remove, "character")
  expect_length(restat$remove, 0L)
  expect_s3_class(restat$new, "data.frame")
  expect_named(restat$new, c("file", "checksum", "built", "date"))
  expect_named(restat$old, c("file", "checksum", "built", "date"))
  expect_equal(restat$checksum, restat$checksum)

})



test_that("get_child_files() will return a list of files that have child documents in lessons", {

  # setup our test and then burn it down
  files <- setup_child_test(res)
  withr::defer(fs::file_delete(files))

  lsn <- this_lesson(res)
  expected <- list("child-haver.Rmd" = c("files/figures.md"))
  expect_type(get_child_files(lsn), "list")
  expect_equal(get_child_files(lsn), expected)

})



test_that("build_status() _always_ requires parent documents to rebuild", {

  # setup our test and then burn it down
  files <- setup_child_test(res)
  withr::defer(fs::file_delete(files))

  outdir <- path_built(res)
  db_path <- fs::path(outdir, "md5sum.txt")
  # database should not exist
  expect_false(fs::file_exists(db_path))
  withr::defer({
    if (fs::file_exists(db_path)) {
      fs::file_delete(db_path)
    }
  })

  # the table starts out empty
  db <- get_built_db(db_path)
  expect_s3_class(db, "data.frame")
  expect_equal(nrow(db), 0L)
  expect_named(db, c("file", "checksum", "built"))

  sources <- get_build_sources(res, outdir, slug = NULL, quiet = TRUE)
  stat <- build_status(sources, db_path, rebuild = FALSE, write = TRUE)

  expect_type(stat, "list")
  expect_named(stat, c("build", "new"))
  # the build stat will be all of the source files
  expect_type(stat$build, "character")
  expect_equal(fs::path_file(stat$build), fs::path_file(sources))
  expect_s3_class(stat$new, "data.frame")
  expect_named(stat$new, c("file", "checksum", "built", "date"))

  # a rerun returns a status where the source with a child document requires
  # a rebuild
  restat <- build_status(sources, db_path, rebuild = FALSE, write = TRUE)

  expect_type(restat, "list")
  expect_named(restat, c("build", "remove", "new", "old"))

  # no source files are changed so nothing is flagged for rebuilding
  expect_type(restat$build, "character")
  expect_length(restat$build, 0L)

  # The hash of our child-haver file is not the md5 sum because we use the hash
  # of the sums of the dependent files.
  haver_hash <- unname(tools::md5sum(fs::path(res, "episodes", "child-haver.Rmd")))
  haver_check <- restat$old$checksum[endsWith(restat$old$file, "child-haver.Rmd")]
  expect_failure(expect_equal(haver_hash, haver_check))

  # no files are to be removed
  expect_type(restat$remove, "character")
  expect_length(restat$remove, 0L)

  # the checksums are identical
  expect_s3_class(restat$new, "data.frame")
  expect_named(restat$new, c("file", "checksum", "built", "date"))
  expect_named(restat$old, c("file", "checksum", "built", "date"))
  expect_equal(restat$checksum, restat$checksum)

  # when the child file is modified, the parent file needs to be rebuilt
  child_file <- fs::path(res, "episodes", "files", "figures.md")
  cat("\nthis is just to say\n\ttest\n", file = child_file, append = TRUE)

  restat <- build_status(sources, db_path, rebuild = FALSE, write = TRUE)
  expect_type(restat, "list")
  expect_named(restat, c("build", "remove", "new", "old"))

  # no source files are changed so nothing is flagged for rebuilding
  expect_type(restat$build, "character")
  expect_length(restat$build, 1L)
  expect_equal(fs::path_file(restat$build), "child-haver.Rmd")

})





