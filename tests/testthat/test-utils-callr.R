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
    expect_output("lesson-requirements") # Looking for a report of the lesson-requirements profile from {renv}
  })
  expect_true(fs::file_exists(o2))
  # our R expression was evaluated
  expect_match(grep("Hello", readLines(o2), value = TRUE), "Hello from R (version|Under)")
  # The CSS code is evaluated
  expect_match(grep("css", readLines(o2), value = TRUE), "style type=.text/css.")

})


test_that("callr_build_episode_md() injects lesson config and snippets", {
  lsn <- fs::file_temp(pattern = "lesson-")
  out <- fs::file_temp(pattern = "render-")
  ep <- fs::path(lsn, "episodes", "example.Rmd")
  out_md <- fs::path(out, "example.md")

  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "demo"), recurse = TRUE)
  fs::dir_create(out)

  writeLines(c(
    "use_snippets: true",
    "base_snippets: base"
  ), fs::path(lsn, "config.yaml"))

  writeLines(c(
    "snippets: base",
    "remote:",
    "  prompt: '[user@cluster ~]$'"
  ), fs::path(lsn, "episodes", "files", "customization", "base", "_config_options.yml"))

  writeLines("Snippet says `r config$remote$prompt`", fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "demo", "line.Rmd"))

  writeLines(c(
    "---",
    "title: demo",
    "---",
    "",
    "Prompt: `r config$remote$prompt`",
    "",
    "```{r, echo=FALSE, results='asis'}",
    "snippets('demo/line.Rmd')",
    "```"
  ), ep)

  withr::defer(fs::dir_delete(lsn))
  withr::defer(fs::dir_delete(out))

  callr_build_episode_md(
    path = ep,
    hash = NULL,
    workenv = new.env(),
    outpath = out_md,
    workdir = out,
    root = "",
    quiet = TRUE,
    error = TRUE
  )

  rendered <- paste(readLines(out_md), collapse = "\n")
  expect_match(rendered, "Prompt: \\[user@cluster ~\\]\\$")
  expect_match(rendered, "Snippet says \\[user@cluster ~\\]\\$")
})


test_that("callr_build_episode_md() skips customization when snippets are disabled", {
  lsn <- fs::file_temp(pattern = "lesson-")
  out <- fs::file_temp(pattern = "render-")
  ep <- fs::path(lsn, "episodes", "example.Rmd")
  out_md <- fs::path(out, "example.md")

  fs::dir_create(fs::path(lsn, "episodes"), recurse = TRUE)
  fs::dir_create(out)

  writeLines("title: demo", fs::path(lsn, "config.yaml"))
  writeLines(c(
    "---",
    "title: demo",
    "---",
    "",
    "Has config object: `r exists('config')`"
  ), ep)

  withr::defer(fs::dir_delete(lsn))
  withr::defer(fs::dir_delete(out))

  callr_build_episode_md(
    path = ep,
    hash = NULL,
    workenv = new.env(),
    outpath = out_md,
    workdir = out,
    root = "",
    quiet = TRUE,
    error = TRUE
  )

  rendered <- paste(readLines(out_md), collapse = "\n")
  expect_match(rendered, "Has config object: FALSE")
})


test_that("build_episode_md() errors clearly when config placeholders are used without snippets settings", {
  lsn <- fs::file_temp(pattern = "lesson-")
  out <- fs::file_temp(pattern = "render-")
  ep <- fs::path(lsn, "episodes", "example.Rmd")

  fs::dir_create(fs::path(lsn, "episodes"), recurse = TRUE)
  fs::dir_create(out)

  writeLines("title: demo", fs::path(lsn, "config.yaml"))
  writeLines(c(
    "---",
    "title: demo",
    "---",
    "",
    "```bash",
    "`r config$remote$prompt` `r config$sched$submit$name` `r config$sched$submit$options` example-job.sh",
    "```"
  ), ep)

  withr::defer(fs::dir_delete(lsn))
  withr::defer(fs::dir_delete(out))

  expect_error(
    build_episode_md(ep, outdir = out, workdir = out, quiet = TRUE, error = TRUE),
    "must set `use_snippets: true` and a valid `base_snippets`"
  )
})
