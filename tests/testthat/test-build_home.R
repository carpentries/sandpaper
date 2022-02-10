res <- restore_fixture()


test_that("build_home() works independently", {
  pkg <- pkgdown::as_pkgdown(path_site(res))
  expect_output(pkgdown::init_site(pkg))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "index.html")))
  build_episode_md(fs::path(res, "index.md"), quiet = TRUE)
  build_home(pkg, quiet = FALSE, new_setup = TRUE, 
    next_page = fs::path(res, "episodes", "01-introduction.Rmd")
  )
  expect_true(fs::file_exists(fs::path(pkg$dst_path, "index.html")))
  print(fs::dir_ls(pkg$dst_path))

})

