res <- restore_fixture()


test_that("build_home() works independently", {
  pkg <- pkgdown::as_pkgdown(path_site(res))
  expect_output(pkgdown::init_site(pkg))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "index.html")))
  built_dir <- fs::path(pkg$src_path, "built")
  fs::dir_create(built_dir)
  fs::file_copy(fs::path(res, "index.md"), built_dir)
  fs::file_copy(fs::path(res, "learners", "setup.md"), built_dir)
  build_home(pkg, quiet = FALSE, new_setup = TRUE, 
    next_page = fs::path(res, "episodes", "01-introduction.Rmd")
  )
  learn_index <- fs::path(pkg$dst_path, "index.html")
  expect_true(fs::file_exists(learn_index))
  html <- xml2::read_html(learn_index)

  
  
  instruct_index <- fs::path(pkg$dst_path, "instructor", "index.html")
  expect_true(fs::file_exists(instruct_index))
})

