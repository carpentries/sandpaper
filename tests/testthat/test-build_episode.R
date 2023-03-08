res <- tmp <- restore_fixture()


test_that("build_episode_html() returns nothing for an empty page", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::path(res, "DELETEME")
  withr::local_file(tmp)
  writeLines("---\nlayout: what\n---\n\n", tmp)
  expect_null(build_episode_html(tmp, quiet = TRUE))
})


test_that("build_episode functions works independently", {

  withr::local_options(list(sandpaper.use_renv = FALSE))
  pkg <- pkgdown::as_pkgdown(file.path(tmp, "site"))
  expect_output(pkgdown::init_site(pkg))


  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # create a new file in extras
  fun_file <- file.path(tmp, "episodes", "files", "fun.Rmd")
  file.copy(test_path("examples/s3.Rmd"), fun_file, overwrite = TRUE)
  expect_true(fs::file_exists(fun_file))

  skip_on_os("windows")
  # expect_output({
    res <- build_episode_md(fun_file, workdir = dirname(fun_file))
  # }, processing_(fun_file))

  expect_equal(basename(res), "fun.md")
  expect_true(file.exists(file.path(tmp, "site", "built", "fun.md")))
  lines <- readLines(res)
  expect_equal(lines[[2]], "title: Fun times")
  from_r <- grep("This is coming from", lines)
  expect_match(lines[from_r], "This is coming from R (version|Under)")

  # Explicitly testing https://github.com/carpentries/sandpaper/issues/288
  # If we specify a `new.env()`, then the S3 dispatch will not work, but when we
  # default to `globalenv()`, the S3 dispatch works.
  expect_false(any(grepl("Error", lines)))

  expect_false(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  expect_false(file.exists(file.path(tmp, "site", "docs", "instructor", "fun.html")))
  expect_output({
    build_episode_html(res,
      fun_file,
      page_back = fun_file,
      page_forward = fun_file,
      pkg = pkg
    )
  }, "Writing 'fun.html'")
  expect_true(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  expect_true(file.exists(file.path(tmp, "site", "docs", "instructor", "fun.html")))
})


test_that("the chapter-links should be cromulent depending on the view", {

  skip_if_not(file.exists(file.path(tmp, "site", "docs", "fun.html")))
  skip_if_not(file.exists(file.path(tmp, "site", "docs", "instructor", "fun.html")))
  instruct <- fs::path(tmp, "site", "docs", "instructor", "fun.html")
  learn    <- fs::path(tmp, "site", "docs", "fun.html")
  instruct <- xml2::read_html(instruct)
  learn    <- xml2::read_html(learn)

  internal_learn_links <- xml2::xml_find_all(learn, ".//a[contains(text(), 'internal')]")
  expect_length(internal_learn_links, 1L)
  expect_equal(xml2::xml_attr(internal_learn_links, "href"), "fun.html")

  learn_links <- xml2::xml_find_all(learn, ".//a[@class='chapter-link']")
  expect_length(learn_links, 4L)
  expect_equal(xml2::xml_attr(learn_links, "href"), rep("fun.html", 4L))

  learn_note<- xml2::xml_find_all(learn,
    ".//div[starts-with(@id, 'accordionInstructor')]")
  expect_length(learn_note, 0L)

  instruct_links <- xml2::xml_find_all(instruct, ".//a[@class='chapter-link']")
  expect_length(instruct_links, 4L)
  expect_equal(xml2::xml_attr(instruct_links, "href"),
    rep("../instructor/fun.html", 4L))

  internal_instruct_links <- xml2::xml_find_all(instruct, ".//a[contains(text(), 'internal')]")
  expect_length(internal_instruct_links, 1L)
  expect_equal(xml2::xml_attr(internal_instruct_links, "href"), "fun.html")

  instruct_note <- xml2::xml_find_all(instruct,
    ".//div[starts-with(@id, 'accordionInstructor')]")
  expect_length(instruct_note, 1L)
  IN_lines <- trimws(xml2::xml_text(instruct_note))
  expect_match(IN_lines, "Instructor Note\\s+this is an instructor note")

})

