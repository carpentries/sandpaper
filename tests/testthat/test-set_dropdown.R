{
tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp    <- fs::path(tmpdir, "lesson-example")
withr::defer(fs::dir_delete(tmp))
res <- create_lesson(tmp, open = FALSE)
}

test_that("schedule is empty by default", {

  cfg <- get_config(tmp)
  suppressMessages(s <- get_episodes(tmp))
  expect_equal(s, "01-introduction.Rmd", ignore_attr = TRUE)
  expect_null(set_episodes(tmp, s, write = TRUE))
  expect_silent(s <- get_episodes(tmp))
  expect_equal(s, "01-introduction.Rmd", ignore_attr = TRUE)

  # the config files should be unchanged from the schedule
  no_episodes <- names(cfg)[names(cfg) != "episodes"]
  expect_equal(cfg[no_episodes], get_config(tmp)[no_episodes])

})

test_that("new episodes will not add to the schedule by default", {

  set_episodes(tmp, "01-introduction.Rmd", write = TRUE)
  create_episode("new", path = tmp)
  expect_equal(get_episodes(tmp), "01-introduction.Rmd", ignore_attr = TRUE)

})


test_that("get_episodes() returns episodes in dir if schedule is not set", {

  reset_episodes(tmp)
  suppressMessages(expect_message(s <- get_episodes(tmp)))
  expect_equal(s, c("01-introduction.Rmd", "02-new.Rmd"), ignore_attr = TRUE)
  set_episodes(tmp, s[1], write = TRUE)
  expect_equal(get_episodes(tmp), s[1], ignore_attr = TRUE)

})


cli::test_that_cli("set_episodes() will display the modifications if write is not specified", {

  # Is this skipped on CRAN?
  reset_episodes(tmp)
  expect_snapshot(s <- get_episodes(tmp))

  expect_equal(s, c("01-introduction.Rmd", "02-new.Rmd"))
  set_episodes(tmp, s, write = TRUE)
  expect_equal(get_episodes(tmp), s, ignore_attr = TRUE)

  expect_snapshot(set_episodes(tmp, s[1]))
  expect_equal(get_episodes(tmp), s, ignore_attr = TRUE)
  set_episodes(tmp, s[1], write = TRUE)
  expect_equal(get_episodes(tmp), s[1], ignore_attr = TRUE)

}, configs = "plain")

test_that("set_episodes() will error if no proposal is defined", {

  expect_error(set_episodes(tmp), "episodes must have an order")

})


test_that("adding episodes will concatenate the schedule", {

  set_episodes(tmp, "01-introduction.Rmd", write = TRUE)
  expect_equal(get_episodes(tmp), "01-introduction.Rmd")
  create_episode("second-episode", add = TRUE, path = tmp)
  expect_equal(res, tmp, ignore_attr = TRUE)
  expect_equal(get_episodes(tmp), c("01-introduction.Rmd", "03-second-episode.Rmd"), ignore_attr = TRUE)

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yaml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[2L]]$menu
  expect_length(yaml, 2)
  expect_equal(yaml[[c(1, 3)]], "01-introduction.html")
  expect_equal(yaml[[c(2, 3)]], "03-second-episode.html")


})

test_that("the schedule can be rearranged", {

  set_episodes(tmp, c("03-second-episode.Rmd", "01-introduction.Rmd"), write = TRUE)
  expect_equal(get_episodes(tmp), c("03-second-episode.Rmd", "01-introduction.Rmd"), ignore_attr = TRUE)

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yaml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[2L]]$menu
  expect_length(yaml, 2)
  expect_equal(yaml[[c(1, 3)]], "03-second-episode.html")
  expect_equal(yaml[[c(2, 3)]], "01-introduction.html")

})

test_that("yaml lists are preserved with other schedule updates", {
  
  set_episodes(tmp, c("03-second-episode.Rmd", "01-introduction.Rmd"), write = TRUE)
  # regression test for https://github.com/carpentries/sandpaper/issues/53
  expect_equal(get_episodes(tmp), c("03-second-episode.Rmd", "01-introduction.Rmd"), ignore_attr = TRUE)
  set_learners(tmp, order = "Setup.md", write = TRUE)
  expect_equal(get_episodes(tmp), c("03-second-episode.Rmd", "01-introduction.Rmd"), ignore_attr = TRUE)

})

test_that("the schedule can be truncated", {

  set_episodes(tmp, "01-introduction.Rmd", write = TRUE)
  expect_equal(get_episodes(tmp), "01-introduction.Rmd", ignore_attr = TRUE)

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  yaml <- yaml::read_yaml(path_site_yaml(tmp))$navbar$left[[2L]]$menu
  expect_length(yaml, 1)
  expect_equal(yaml[[c(1, 3)]], "01-introduction.html")

})
