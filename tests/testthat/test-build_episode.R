test_that("build_episode_md() works independently", {

  fun_dir <- fs::file_temp()
  fs::dir_create(fun_dir)
  withr::defer(fs::dir_delete(fun_dir))

  fun_file <- file.path(fun_dir, "fun.Rmd")
  file.create(fun_file)
  txt <- c(
    "---\ntitle: Fun times\n---\n\n",
    "# new page\n", 
    "This is coming from `r R.version.string`"
  )
  writeLines(txt, fun_file)
  hash <- tools::md5sum(fun_file)
  expect_output({
    res <- build_episode_md(fun_file, hash, outdir = fun_dir, workdir = fun_dir)
  }, "inline R code fragments")

  expect_equal(basename(res), "fun.md")
  lines <- readLines(res)
  expect_equal(lines[[2]], paste("sandpaper-digest:", hash))
  expect_equal(lines[[3]], paste("sandpaper-source:", fun_file))
  expect_match(lines[length(lines)], "This is coming from R (version|Under)")

})

test_that("build_episode_html() works independently", {


  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")
  expect_equal(basename(create_lesson(tmp, open = FALSE)), basename(tmp))
  reset_site(tmp)
  pkg <- pkgdown::as_pkgdown(file.path(tmp, "site"))
  expect_output(pkgdown::init_site(pkg))
  

  # create a new file in extras
  fun_file <- file.path(tmp, "episodes", "files", "fun.Rmd")
  txt <- c(
    "---\ntitle: Fun times\n---\n\n",
    "# new page\n", 
    "This is coming from `r R.version.string`"
  )
  file.create(fun_file)
  writeLines(txt, fun_file)
  hash <- tools::md5sum(fun_file)

  expect_output({
    res <- build_episode_md(fun_file, hash, workdir = dirname(fun_file))
  }, "inline R code fragments")

  expect_equal(basename(res), "fun.md")
  expect_true(file.exists(file.path(tmp, "site", "built", "fun.md")))
  lines <- readLines(res)
  expect_equal(lines[[2]], paste("sandpaper-digest:", hash))
  expect_match(lines[length(lines)], "This is coming from R (version|Under)")

  expect_false(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  expect_output({
    build_episode_html(res, 
      page_back = "index.md",
      page_forward = "index.md",
      pkg = pkg
    )
  }, "Writing 'fun.html'")
  expect_true(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  html <- readLines(file.path(tmp, "site", "docs", "fun.html"))
  the_line_bart <- lines[grep("This is coming from R (version|Under)", lines)]
  expect_length(the_line_bart, 1L)

})
