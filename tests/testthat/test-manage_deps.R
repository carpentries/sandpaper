lsn <- restore_fixture()

cli::test_that_cli("package cache message appears correct", {

  msg <- readLines(system.file("resources/WELCOME", package = "renv"))
  msg <- gsub("${RENV_PATHS_ROOT}", dQuote("/path/to/cache"), msg, fixed = TRUE)
  expect_snapshot(cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n"))

})

test_that("use_package_cache() will report consent implied if renv cache is present", {

  skip_on_cran()
  skip_on_os("windows")
  skip_if_not(fs::dir_exists(renv::paths$root()))
  withr::local_options(list(sandpaper.use_renv = FALSE))
  expect_false(getOption("sandpaper.use_renv"))

  use_package_cache(prompt = FALSE, quiet = TRUE)
  expect_true(getOption("sandpaper.use_renv"))

  # a consent message is printed
  suppressMessages({
    expect_message(
      use_package_cache(prompt = TRUE, quiet = FALSE),
      "Consent to use package cache provided"
    )
  })
  expect_true(getOption("sandpaper.use_renv"))

})


test_that("no_package_cache() will report revocation of consent", {
  withr::local_options(list("sandpaper.use_renv" = TRUE))
  expect_true(getOption("sandpaper.use_renv"))
  expect_message(no_package_cache(), "Consent for package cache revoked")
  expect_false(getOption("sandpaper.use_renv"))
  use_package_cache(prompt = FALSE, quiet = TRUE)
  expect_true(getOption("sandpaper.use_renv"))
})


test_that("manage_deps() will create a renv folder", {

  skip_on_cran()
  skip_on_os("windows")
  withr::local_options(list("renv.verbose" = TRUE))
  rnv <- fs::path(lsn, "renv")
  # need to move renv folder outside of the lesson or it will detect the
  # suggested packages within the package and chaos will ensue
  tmp <- withr::local_tempfile()
  fs::dir_create(tmp)
  fs::file_move(rnv, tmp)
  withr::defer({
    fs::dir_delete(rnv)
    fs::file_move(fs::path(tmp, "renv"), rnv)
  })
  expect_false(fs::dir_exists(rnv))

  # NOTE: these tests are still not very specific here...
  suppressMessages({
    capture.output(build_markdown(lsn, quiet = FALSE)) %>%
      expect_message("Consent to use package cache provided")
  })

  expect_true(fs::dir_exists(rnv))
  expect_false(
    renv_should_rebuild(lsn,
      rebuild = FALSE,
      db_path = fs::path(path_built(lsn), "md5sum.txt")
    )
  )

})

test_that("manage_deps() will run without callr", {

  skip_on_cran()
  skip_on_os("windows")
  withr::local_options(list("renv.verbose" = TRUE))
  withr::local_envvar(list(
    "RENV_PROFILE" = "lesson-requirements",
    "R_PROFILE_USER" = fs::path(tempfile(), "nada"),
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache_available()
  ))

  # 2023-08-21
  # I found a slowdown here when running this interactively, which was
  # fixed by setting `prompt = FALSE` when we were testing in `renv::hydrate`
  suppressMessages({
  callr_manage_deps(lsn,
    repos = renv_carpentries_repos(),
    snapshot = TRUE,
    lockfile_exists = TRUE) %>%
    expect_message("Restoring any dependency versions") %>%
    expect_output("package dependencies")
  })


})


test_that("renv will not trigger a rebuild when nothing changes", {

  skip_on_cran()
  skip_on_os("windows")
  # nothing changes, so we do not rebuild
  db_path <- fs::path(path_built(lsn), "md5sum.txt")
  profile <- "lesson-requirements"

  expect_false(
    renv_should_rebuild(lsn,
      rebuild = FALSE,
      db_path = fs::path(path_built(lsn), "md5sum.txt")
    )
  )
  withr::defer(package_cache_trigger(FALSE))
  package_cache_trigger(TRUE)
  lh <- renv_lockfile_hash(lsn, db_path, profile)
  expect_equal(lh$old, lh$new, ignore_attr = TRUE)

  # nothing changes, so we do not rebuild
  expect_false(
    renv_should_rebuild(lsn, rebuild = FALSE, db_path, profile)
  )

})


test_that("pin_version() will use_specific versions", {

  skip_on_cran()
  skip_on_os("windows")
  skip_if_offline()

  withr::local_options(list("renv.verbose" = TRUE))
  withr::local_envvar(list(
    "RENV_PROFILE" = "lesson-requirements",
    "R_PROFILE_USER" = fs::path(tempfile(), "nada"),
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache_available()
  ))

  writeLines("library(sessioninfo)", con = fs::path(lsn, "episodes", "si.R"))
  expect_output({
    pin_version("sessioninfo@1.1.0", path = fs::path(lsn, "episodes")) # old version of sessioninfo
  }, "Updated 1 record in")

  # Need to consider this because there is something happening inside of covr
  # that might make provisioning packages a tricky business.
  skip_if(covr::in_covr())

  withr::local_options(list("renv.verbose" = FALSE))
  suppressMessages({
    capture.output(res <- manage_deps(lsn))
  })

  # sessioninfo 1.2.0 dropped withr as a dependency, so we should
  # expect it to appear here
  expect_false(is.null(res$Packages$withr))
  expect_equal(res$Packages$sessioninfo$Version, "1.1.0")

})


test_that("Package cache changes will trigger a rebuild", {

  skip_on_cran()
  skip_on_os("windows")
  # nothing changes, so we do not rebuild
  db_path <- fs::path(path_built(lsn), "md5sum.txt")
  profile <- "lesson-requirements"

  # default: no rebuilding
  expect_false(renv_should_rebuild(lsn, rebuild = FALSE, db_path = db_path))
  withr::defer(package_cache_trigger(FALSE))
  # explicitly allow package cache to rebuild
  package_cache_trigger(TRUE)
  lh <- renv_lockfile_hash(lsn, db_path, profile)
  # lockfile changed
  expect_false(lh$old == lh$new)

  # The lockfile has changed, so we rebuild
  expect_true(
    renv_should_rebuild(lsn, rebuild = FALSE, db_path, profile)
  )

  # explicitly forbid package cache changes from rebuilding
  package_cache_trigger(FALSE)
  lh <- renv_lockfile_hash(lsn, db_path, profile)
  # lockfile changed
  expect_false(lh$old == lh$new)

  # We do not rebuild
  expect_false(
    renv_should_rebuild(lsn, rebuild = FALSE, db_path, profile)
  )

})


test_that("update_cache() will update old package versions", {

  skip_on_cran()
  skip_on_os("windows")
  skip_if_offline()
  skip_if(covr::in_covr())

  pkg <- "sessioninfo"
  old_pkg_version <- "1.1.0"
  pin_version(glue::glue("{pkg}@{old_pkg_version}"), path = fs::path(lsn, "episodes"))

  res <- update_cache(path = fs::path(lsn, "episodes"), prompt = FALSE, quiet = FALSE)
  expect_true(
    package_version(res[[pkg]]$Version) > package_version(old_pkg_version)
  )

})

reticulate_installable <- check_reticulate_installable()
use_python(lsn, type = "virtualenv", open = FALSE, quiet = TRUE)

test_that("manage_deps() does not overwrite requirements.txt", {
  skip_if_not(reticulate_installable, "reticulate is not installable")
  skip_on_cran()
  skip_on_os("windows")

  old_wd <- setwd(lsn)
  withr::defer(setwd(old_wd))

  ## Set up Python and manually add requirements.txt without actually installing
  ## the Python package, mimicking the scenario where a Python dependency is missing
  req_file <- fs::path(lsn, "requirements.txt")
  if (file.exists(req_file)) fs::file_delete(req_file)
  numpy_version <- "numpy==1.26.4"
  writeLines(numpy_version, req_file)

  res <- manage_deps(lsn, quiet = TRUE)
  expect_true(numpy_version %in% readLines(req_file))
})


test_that("manage_deps() restores Python dependencies", {
  skip_if_not(reticulate_installable, "reticulate is not installable")
  skip_on_cran()
  skip_on_os("windows")

  req_file <- fs::path(lsn, "requirements.txt")
  if (file.exists(req_file)) fs::file_delete(req_file)
  writeLines("numpy", req_file)
  res <- manage_deps(lsn, quiet = TRUE)

  expect_no_error({numpy <- local_load_py_pkg(lsn, "numpy")})
  expect_s3_class(numpy, "python.builtin.module")
})


test_that("update_cache does not remove uninstalled Python dependencies from requirements.txt", {
  skip_if_not(reticulate_installable, "reticulate is not installable")
  skip_on_cran()
  skip_on_os("windows")

  req_file <- fs::path(lsn, "requirements.txt")
  write("art", req_file, append = TRUE, sep = "\n")

  res <- update_cache(lsn, prompt = FALSE, quiet = FALSE)
  expect_true(any(grepl("art", readLines(req_file))))
})
