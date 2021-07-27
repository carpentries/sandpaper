{
  res <- restore_fixture()
  create_episode("new", add = FALSE, path = res)
}

cli::test_that_cli("Default state reports all episodes published", {

  expect_snapshot(drf <- get_drafts(res, "episodes"))
  expect_length(drf, 0)

})

cli::test_that_cli("Draft episodes are and added episodes ignored", {

  reset_episodes(res)
  suppressMessages(set_episodes(res, get_episodes(res)[1], write = TRUE))
  expect_snapshot(drf <- get_drafts(res, "episodes"))
  expect_equal(fs::path_file(drf), "02-new.Rmd", ignore_attr = TRUE)

})


cli::test_that_cli("No draft episodes reports all episodes published", {

  reset_episodes(res)
  suppressMessages(set_episodes(res, get_episodes(res), write = TRUE))
  expect_snapshot(drf <- get_drafts(res, "episodes"))
  expect_length(drf, 0)

})


