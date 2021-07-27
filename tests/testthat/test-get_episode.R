{
tmp <- res <- restore_fixture()
suppressMessages(e <- get_episodes(res))
set_episodes(res, e, write = TRUE)
}

cli::test_that_cli("set_episode() will throw an error if an episode does not exist", {

  bad <- c(e, "I-do-not-exist.md")

  expect_snapshot(expect_error(set_episodes(res, bad, write = TRUE)))

  expect_silent(bad_out <- get_episodes(res))

  # The output equals the only episode in there
  expect_equal(bad_out, e)

})

cli::test_that_cli("get_episode() will throw a message about episode in draft", {

  withr::local_options(list("sandpaper.show_draft" = TRUE))
  if (!fs::file_exists(fs::path(res, "episodes", "02-new.Rmd"))) {
    create_episode("new", add = FALSE, path = res)
  }
  expect_snapshot(drafty_out <- get_episodes(res))
  expect_equal(drafty_out, e)

})

cli::test_that_cli("get_episode() will throw a warning if an episode in config does not exist", {

  # Create a new episode that does not exist
  cfg <- readLines(fs::path(res, "config.yaml"), encoding = "UTF-8")
  episode_line <- grep("^episodes", cfg)

  new_cfg <- c(
    cfg[seq(episode_line + 1L)], 
    "- I-am-an-impostor.md", 
    cfg[seq(episode_line + 2L, length(cfg))]
  )

  withr::defer(writeLines(cfg, fs::path(res, "config.yaml")))

  writeLines(new_cfg, fs::path(res, "config.yaml"))

  expect_snapshot(expect_error(get_episodes(res)))

})
