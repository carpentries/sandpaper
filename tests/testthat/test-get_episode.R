{
tmp <- res <- restore_fixture()
suppressMessages(e <- get_episodes(res))
set_episodes(res, e, write = TRUE)
}

test_that("set_episode() will throw a warning if an episode does not exist", {

  bad <- c(e, "I-do-not-exist.md")

  expect_message(set_episodes(res, bad, write = TRUE))

  expect_silent(bad_out <- get_episodes(res))

  expect_equal(bad_out, e)

})

test_that("get_episode() will throw a warning if an episode in config does not exist", {

  # Create a new episode that does not exist
  cfg <- readLines(fs::path(res, "config.yaml"), encoding = "UTF-8")
  episode_line <- grep("^episodes", cfg)

  new_cfg <- c(
    cfg[seq(episode_line + 1L)], 
    "- I-am-an-impostor.md", 
    cfg[seq(episode_line + 2L, length(cfg))]
  )

  writeLines(new_cfg, fs::path(res, "config.yaml"))

  expect_message(bad_out <- get_episodes(res))

  expect_equal(bad_out, e)

})
