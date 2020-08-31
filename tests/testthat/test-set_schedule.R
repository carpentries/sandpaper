tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp    <- fs::path(tmpdir, "lesson-example")
withr::defer(fs::dir_delete(tmp))
res <- create_lesson(tmp)

test_that("template has no schedule element", {
  expect_null(yaml::read_yaml(template_config())$schedule)
})

test_that("adding episodes will concatenate the schedule", {

  expect_equal(get_schedule(tmp), "01-introduction.Rmd")
  create_episode("second-episode", path = tmp)
  expect_equal(res, tmp, ignore_attr = TRUE)
  expect_equal(get_schedule(tmp), c("01-introduction.Rmd", "02-second-episode.Rmd"))
  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[1]]$menu
  expect_length(yml, 2)
  expect_equal(yml[[c(1, 3)]], "01-introduction.html")
  expect_equal(yml[[c(2, 3)]], "02-second-episode.html")


})

test_that("the schedule can be rearranged", {

  set_schedule(tmp, rev(get_schedule(tmp)), write = TRUE)
  expect_equal(get_schedule(tmp), c("02-second-episode.Rmd", "01-introduction.Rmd"))
  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[1]]$menu
  expect_length(yml, 2)
  expect_equal(yml[[c(1, 3)]], "02-second-episode.html")
  expect_equal(yml[[c(2, 3)]], "01-introduction.html")

})

test_that("the schedule can be truncated", {

  set_schedule(tmp, rev(get_schedule(tmp))[1], write = TRUE)
  expect_equal(get_schedule(tmp), "01-introduction.Rmd")
  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[1]]$menu
  expect_length(yml, 1)
  expect_equal(yml[[c(1, 3)]], "01-introduction.html")

})
