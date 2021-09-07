lsn <- restore_fixture()

cli::test_that_cli("pacakge cache message appears correct", {

  msg <- readLines(system.file("resources/WELCOME", package = "renv"))
  msg <- gsub("${RENV_PATHS_ROOT}", dQuote("/path/to/cache"), msg, fixed = TRUE)
  expect_snapshot(cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n"))

})

test_that("use_package_cache() will report consent implied if renv cache is present", {

  skip_on_os("windows")
  skip_if_not(fs::dir_exists(renv::paths$root()))
  withr::local_options(list(sandpaper.use_renv = FALSE))
  expect_false(getOption("sandpaper.use_renv"))

  expect_message(
    use_package_cache(prompt = TRUE, quiet = FALSE),
    "Consent for renv provided---consent for package cache implied."
  )
  expect_message(
    use_package_cache(prompt = TRUE, quiet = FALSE),
    "Consent to use package cache provided"
  )
  expect_true(getOption("sandpaper.use_renv"))

})

test_that("manage_deps() will create a renv folder", {

  skip_on_os("windows")
  rnv <- fs::path(lsn, "renv")
  fs::file_move(rnv, fs::path(lsn, "vner"))
  withr::defer({
    fs::dir_delete(rnv)
    fs::file_move(fs::path(lsn, "vner"), rnv) 
  })
  expect_false(fs::dir_exists(rnv))

  # NOTE: these tests are still not very specific here...
  manage_deps(lsn, quiet = FALSE, snapshot = TRUE) %>%
    expect_message("Consent to use package cache provided") %>%
    expect_output("Lockfile written to") %>%
    expect_s3_class("renv_lockfile")

  expect_true(fs::dir_exists(rnv))

})

test_that("manage_deps() will run without callr", {

  skip_on_os("windows")
  withr::local_envvar(list(
    "RENV_PROFILE" = "lesson-requirements",
    "R_PROFILE_USER" = fs::path(tempfile(), "nada"),
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()
  ))
 
  suppressMessages({
  callr_manage_deps(lsn, 
    repos = renv_carpentries_repos(), 
    snapshot = TRUE, 
    lockfile_exists = TRUE) %>%
    expect_message("Restoring any dependency versions") %>%
    expect_output("Copying packages into the library")
  })

})

test_that("pin_version() will use_specific versions", {
  
  skip_on_os("windows")
  skip_if_offline()
  writeLines("library(sessioninfo)", con = fs::path(lsn, "episodes", "si.R"))
  expect_output({
    pin_version("sessioninfo@1.1.0", path = lsn) # old version of sessioninfo
  }, "Updated 1 record in")

  withr::local_envvar(list(
    "RENV_PROFILE" = "lesson-requirements",
    "R_PROFILE_USER" = fs::path(tempfile(), "nada"),
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache()
  ))

  suppressMessages({
  res <- callr_manage_deps(lsn, 
    repos = renv_carpentries_repos(), 
    snapshot = TRUE, 
    lockfile_exists = TRUE) %>%
    expect_message("Restoring any dependency versions") %>%
    expect_output("sessioninfo")
  })

  expect_equal(res$Packages$sessioninfo$Version, "1.1.0")

})

test_that("fetch_updates() will update old package versions", {
  
  skip_on_os("windows")
  skip_if_offline()

  suppressMessages({
    res <- fetch_updates(path = lsn, prompt = FALSE, quiet = FALSE) %>%
      expect_output("sessioninfo")
  })
  expect_named(res, "sessioninfo")
  expect_true(
    package_version(res$sessioninfo$Version) > package_version("1.1.0")
  )

})
