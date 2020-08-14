test_that("episodes can be created", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # Make sure everything exists
  expect_true(check_lesson(tmp))

  initial_episode <- fs::dir_ls(fs::path(tmp, "episodes"), glob = "*Rmd") %>%
    expect_length(1L) %>%
    expect_match("01-introduction.Rmd")

  initial_episode_md5 <- tools::md5sum(initial_episode)

  second_episode <- create_episode("first-script", path = tmp) %>%
    expect_match("02-first-script.Rmd", fixed = TRUE)

  expect_equal(tools::md5sum(second_episode), initial_episode_md5, ignore_attr = TRUE)

  expect_true(check_episode(initial_episode))
  expect_true(check_episode(second_episode))
 

})
