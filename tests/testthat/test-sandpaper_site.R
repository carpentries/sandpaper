test_that("sandpaper_site produces a renderer", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)
  withr::with_dir(tmp, res <- sandpaper_site())
  expect_type(res, "list")
  expect_named(res, c("name", "output_dir", "render", "clean", "subdirs"))
  expect_true(res$subdirs)
  expect_type(res$render, "closure")
  expect_equal(res$name, get_config(tmp)$title)

})
