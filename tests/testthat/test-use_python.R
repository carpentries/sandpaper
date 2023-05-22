## Set up temporary lesson with Python installed, for use in all subsequent tests
lsn <- restore_fixture()
lsn <- use_python(lsn)

test_that("use_python() adds Python environment", {
  py_path <- fs::path(lsn, "renv/profiles/lesson-requirements/renv/python")
  expect_true(fs::dir_exists(py_path))
})

test_that("reticulate is installed", {
  has_reticulate <- check_reticulate(lsn)
  expect_true(has_reticulate)
})

test_that("use_python() sets reticulate configuration", {
  reticulate_python_env <- get_renv_env(lsn, "RETICULATE_PYTHON")
  py_config <- check_reticulate_config(lsn)

  expect_false(reticulate_python_env == "")
  expect_true(py_config$available)
  expect_true(py_config$forced == "RETICULATE_PYTHON")
})


## This relates to a bug in renv, see https://github.com/rstudio/renv/issues/1217
test_that("use_python() does not remove renv/profile", {
  expect_true(fs::file_exists(fs::path(lsn, "renv/profile")))
})

test_that("py_install() installs Python packages", {
  py_install("numpy", path = lsn)
  numpy <- local_load_py_pkg(lsn, "numpy")

  expect_no_error({numpy <- reticulate::import("numpy")})
  expect_s3_class(numpy, "python.builtin.module")

  req_file <- fs::path(lsn, "requirements.txt")
  expect_true(grepl("^numpy", readLines(req_file)))
})
