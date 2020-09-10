tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp    <- fs::path(tmpdir, "lesson-example")
withr::defer(fs::dir_delete(tmp))
res <- create_lesson(tmp, open = FALSE)

test_that("schedule is empty by default", {

  cfg <- get_config(tmp)
  expect_warning(s <- get_schedule(tmp), "set_schedule")
  expect_equal(s, "01-introduction.Rmd")
  expect_null(set_schedule(tmp, s, write = TRUE))
  expect_silent(s <- get_schedule(tmp))
  expect_equal(s, "01-introduction.Rmd")

  # the config files should be unchanged from the schedule
  expect_equal(cfg[-length(cfg)], get_config(tmp)[-length(cfg)])

})

test_that("new episodes will not add to the schedule by default", {

  set_schedule(tmp, "01-introduction.Rmd", write = TRUE)
  create_episode("new", path = tmp)
  expect_equal(get_schedule(tmp), "01-introduction.Rmd")

})


test_that("get_schedule() returns episodes in dir if schedule is not set", {

  clear_schedule(tmp)
  expect_warning(s <- get_schedule(tmp), "set_schedule")
  expect_equal(s, c("01-introduction.Rmd", "02-new.Rmd"))
  set_schedule(tmp, s[1], write = TRUE)
  expect_equal(get_schedule(tmp), s[1])

})

test_that("adding episodes will concatenate the schedule", {

  expect_equal(get_schedule(tmp), "01-introduction.Rmd")
  create_episode("second-episode", add = TRUE, path = tmp)
  expect_equal(res, tmp, ignore_attr = TRUE)
  expect_equal(get_schedule(tmp), c("01-introduction.Rmd", "03-second-episode.Rmd"))
  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[1]]$menu
  expect_length(yml, 2)
  expect_equal(yml[[c(1, 3)]], "01-introduction.html")
  expect_equal(yml[[c(2, 3)]], "03-second-episode.html")


})

test_that("the schedule can be rearranged", {

  set_schedule(tmp, rev(get_schedule(tmp)), write = TRUE)
  expect_equal(get_schedule(tmp), c("03-second-episode.Rmd", "01-introduction.Rmd"))
  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[1]]$menu
  expect_length(yml, 2)
  expect_equal(yml[[c(1, 3)]], "03-second-episode.html")
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
