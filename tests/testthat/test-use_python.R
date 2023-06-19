## Set up temporary lesson with Python installed, for use in all subsequent tests
lsn <- restore_fixture()
lsn <- use_python(lsn)

suppressWarnings({
  reticulate_installable <- check_reticulate_installable()
})

test_that("use_python() adds Python environment", {
  skip_on_os("windows")
  py_path <- fs::path(lsn, "renv/profiles/lesson-requirements/renv/python")
  expect_true(fs::dir_exists(py_path))
})

test_that("reticulate is installed", {
  skip_if_not(reticulate_installable, "reticulate is not installable")
  has_reticulate <- check_reticulate(lsn)
  expect_true(has_reticulate)
})

test_that("A warning is generated when reticulate is not installable", {
  skip_if(reticulate_installable, "reticulate is installable")
  expect_warning(install_reticulate(lsn))
  has_reticulate <- check_reticulate(lsn)
  expect_false(has_reticulate)
})

test_that("use_python() sets reticulate configuration", {
  skip_on_os("windows")
  skip_if_not(reticulate_installable, "reticulate is not installable")
  reticulate_python_env <- get_renv_env(lsn, "RETICULATE_PYTHON")
  py_config <- check_reticulate_config(lsn)

  expect_false(reticulate_python_env == "")
  expect_true(py_config$available)
  expect_true(py_config$forced == "RETICULATE_PYTHON")
})


## This relates to a bug in renv, see https://github.com/rstudio/renv/issues/1217
test_that("use_python() does not remove renv/profile", {
  skip_on_os("windows")
  expect_true(fs::file_exists(fs::path(lsn, "renv/profile")))
})

test_that("py_install() installs Python packages", {
  skip_if_not(reticulate_installable, "reticulate is not installable")
  skip_on_os("windows")

  py_install("numpy", path = lsn)
  numpy <- local_load_py_pkg(lsn, "numpy")

  expect_no_error({numpy <- reticulate::import("numpy")})
  expect_s3_class(numpy, "python.builtin.module")

  req_file <- fs::path(lsn, "requirements.txt")
  expect_true(grepl("^numpy", readLines(req_file)))
})
