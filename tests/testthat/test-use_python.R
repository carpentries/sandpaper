lsn <- restore_fixture()
old_wd  <- setwd(lsn)
withr::defer(setwd(old_wd))

use_python(lsn, type = "virtualenv")


test_that("use_python() adds Python environment", {
  py_path <- fs::path(lsn, "renv/profiles/lesson-requirements/renv/python")

  expect_true(fs::dir_exists(py_path))
  expect_false(Sys.getenv("RETICULATE_PYTHON") == "")
  py_config <- reticulate::py_config()
  expect_true(py_config$available)
  expect_true(py_config$forced == "RETICULATE_PYTHON")
})

## This relates to a bug in renv, see https://github.com/rstudio/renv/issues/1217
test_that("use_python() does not remove renv/profile", {
  expect_true(fs::file_exists(fs::path(lsn, "renv/profile")))
})


test_that("py_install() installs Python packages", {
  py_install("numpy", path = lsn)

  expect_no_error({numpy <- reticulate::import("numpy")})
  expect_s3_class(numpy, "python.builtin.module")
})


test_that("py_install() updates requirements.txt", {
  py_install("numpy", path = lsn)
  req_file <- fs::path(lsn, "requirements.txt")
  expect_true(grepl("^numpy", readLines(req_file)))
})
