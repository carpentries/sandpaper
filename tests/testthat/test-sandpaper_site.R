test_that("sandpaper_site produces a renderer", {

  tmp <- res <- restore_fixture()
  withr::with_dir(tmp, res <- sandpaper_site())
  expect_type(res, "list")
  expect_named(res, c("name", "output_dir", "render", "clean", "subdirs"))
  expect_true(res$subdirs)
  expect_type(res$render, "closure")
  expect_equal(res$name, get_config(tmp)$title)

})
