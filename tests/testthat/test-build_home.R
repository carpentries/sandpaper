res <- restore_fixture()
withr::defer(clear_globals())
set_globals(res)
pkg <- pkgdown::as_pkgdown(path_site(res))


test_that("build_home() works independently", {
  expect_output(pkgdown::init_site(pkg))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "index.html")))

  built_dir <- fs::path(pkg$src_path, "built")
  fs::dir_create(built_dir)
  fs::file_copy(fs::path(res, "index.md"), built_dir)
  fs::file_copy(fs::path(res, "learners", "setup.md"), built_dir)
  build_home(pkg, quiet = TRUE, new_setup = TRUE,
    next_page = fs::path(res, "episodes", "01-introduction.Rmd")
  )
  learn_index <- fs::path(pkg$dst_path, "index.html")
  expect_true(fs::file_exists(learn_index))
  instruct_index <- fs::path(pkg$dst_path, "instructor", "index.html")
  expect_true(fs::file_exists(instruct_index))
})


test_that("learner index file is index and setup", {

  learn_index <- fs::path(pkg$dst_path, "index.html")
  expect_true(fs::file_exists(learn_index))
  html <- xml2::read_html(learn_index)
  items <- xml2::xml_find_all(html, ".//div[@class='accordion-body']/ul/li")
  expect_length(items, 2L)
  expect_equal(xml2::xml_text(items), c("Data Sets", "Software Setup"))

  fwd <- xml2::xml_find_all(html, ".//a[starts-with(@class, 'chapter-link')]/@href")
  expect_length(fwd, 4L)
  expect_equal(xml2::xml_text(fwd), rep("01-introduction.html", 4L))

})

test_that("instructor index file is index and schedule", {

  instruct_index <- fs::path(pkg$dst_path, "instructor", "index.html")
  expect_true(fs::file_exists(instruct_index))
  html <- xml2::read_html(instruct_index)
  items <- xml2::xml_find_all(html, ".//div[@class='accordion-body']/ul/li")
  expect_length(items, 1L) 
  expect_equal(xml2::xml_text(items), c("Learner Profiles"))

  fwd <- xml2::xml_find_all(html, ".//a[starts-with(@class, 'chapter-link')]/@href")
  expect_length(fwd, 4L)
  expect_equal(xml2::xml_text(fwd), rep("../instructor/01-introduction.html", 4L))
})

