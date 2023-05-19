{
  lsn <- restore_fixture()
  src <- fs::file_temp(pattern = "-source-")
  out <- fs::file_temp(pattern = "-output-")
  t1 <- fs::path(src, "test1.md")
  o1 <- fs::path(out, "test1.md")
  t2 <- fs::path(src, "test2.Rmd")
  o2 <- fs::path(out, "test2.md")
  fs::dir_create(src)
  fs::dir_create(out)
  copy_template("license", src, "test1.md")
  writeLines("---\ntitle: a\n---\n\nHello from `r R.version.string`\n\n```{css css-chunk}\n#| echo: false\n.my-class {padding: 25px};\n```\n", t2)
  withr::defer({
    fs::dir_delete(src)
    fs::dir_delete(out)
  })
  withr::local_envvar(list("RENV_PROFILE" = "lesson-requirements",
    "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache_available()))
}

test_that("callr_build_episode_md() works with Rmarkdown", {

  expect_false(fs::file_exists(o2))
  suppressMessages({
  callr_build_episode_md(
    path = t2, hash = NULL, workenv = new.env(),
    outpath = o2, workdir = fs::path_dir(o2), root = "", quiet = FALSE
  ) %>%
    expect_message("processing file:")
  })
  expect_true(fs::file_exists(o2))
  expect_match(grep("Hello", readLines(o2), value = TRUE), "Hello from R (version|Under)")
  expect_match(grep("css", readLines(o2), value = TRUE), "style type=.text/css.")

})

test_that("callr_build_episode_md() works with Rmarkdown using renv", {

  skip_on_os("windows")
  withr::local_options(list("renv.verbose" = TRUE))

  fs::file_delete(o2)
  expect_false(fs::file_exists(o2))
  suppressMessages({
  callr_build_episode_md(
    path = t2, hash = NULL, workenv = new.env(),
    outpath = o2, workdir = fs::path_dir(o2), root = lsn, quiet = TRUE
  ) %>%
    expect_output("\\(lesson-requirements\\)")
  })
  expect_true(fs::file_exists(o2))
  expect_match(grep("Hello", readLines(o2), value = TRUE), "Hello from R (version|Under)")
  expect_match(grep("css", readLines(o2), value = TRUE), "style type=.text/css.")

})
