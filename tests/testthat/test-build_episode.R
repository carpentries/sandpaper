test_that("build_episode_md() works independently", {
  
  withr::local_options(list(sandpaper.use_renv = FALSE))

  fun_dir <- fs::file_temp()
  fs::dir_create(fun_dir)
  fs::dir_create(fs::path(fun_dir, "episodes"))
  withr::defer(fs::dir_delete(fun_dir))

  fun_file <- file.path(fun_dir, "episodes", "fun.Rmd")
  file.create(fun_file)
  txt <- c(
    "---\ntitle: Fun times\n---\n\n",
    "# new page\n", 
    "This is coming from `r R.version.string`"
  )
  writeLines(txt, fun_file)
  expect_output({
    res <- build_episode_md(fun_file, outdir = fun_dir, workdir = fun_dir)
  }, "inline R code fragments")

  expect_equal(basename(res), "fun.md")
  lines <- readLines(res)
  expect_match(lines[[2]], "title: Fun times")
  expect_match(lines[length(lines)], "This is coming from R (version|Under)")

})


test_that("build_episode_html() returns nothing for an empty page", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::path(res, "DELETEME")
  withr::local_file(tmp)
  writeLines("---\nlayout: what\n---\n\n", tmp)
  expect_null(build_episode_html(tmp, quiet = TRUE))
})


test_that("build_episode_html() works independently", {


  withr::local_options(list(sandpaper.use_renv = FALSE))
  tmp <- restore_fixture()
  pkg <- pkgdown::as_pkgdown(file.path(tmp, "site"))
  expect_output(pkgdown::init_site(pkg))
  

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # create a new file in extras
  fun_file <- file.path(tmp, "episodes", "files", "fun.Rmd")
  txt <- c(
    "---\ntitle: Fun times\n---\n\n",
    "# new page\n", 
    "This is coming from `r R.version.string`\n",
    "::: instructor",
    "this is an instructor note",
    ":::"
  )
  file.create(fun_file)
  writeLines(txt, fun_file)

  skip_on_os("windows")
  manage_deps(tmp)
  expect_output({
    res <- build_episode_md(fun_file, workdir = dirname(fun_file))
  }, "inline R code fragments")

  expect_equal(basename(res), "fun.md")
  expect_true(file.exists(file.path(tmp, "site", "built", "fun.md")))
  lines <- readLines(res)
  expect_equal(lines[[2]], "title: Fun times")
  from_r <- grep("This is coming from", lines)
  expect_match(lines[from_r], "This is coming from R (version|Under)")

  expect_false(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  expect_false(file.exists(file.path(tmp, "site", "docs", "instructor", "fun.html")))
  expect_output({
    build_episode_html(res, 
      fun_file,
      page_back = "index.md",
      page_forward = "index.md",
      pkg = pkg
    )
  }, "Writing 'fun.html'")
  expect_true(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  expect_true(file.exists(file.path(tmp, "site", "docs", "instructor", "fun.html")))

  # The learner view should not have an instructor note
  lines <- readLines(file.path(tmp, "site", "docs", "fun.html"))
  the_line_bart <- lines[grep("This is coming from R (version|Under)", lines)]
  expect_length(the_line_bart, 1L)
  the_line_bort <- lines[grep("this is an instructor note", lines)]
  expect_length(the_line_bort, 0L)

  # the instructor view shoudl have the instructor note
  lines <- readLines(file.path(tmp, "site", "docs", "instructor", "fun.html"))
  the_line_bart <- lines[grep("this is an instructor note", lines)]
  expect_length(the_line_bart, 1L)

})


