{
  res <- restore_fixture()
  suppressMessages({
    create_episode("new", path = res, open = FALSE)
  })
}

cli::test_that_cli("Default state reports all episodes published", {

  reset_episodes(res)
  expect_snapshot(drf <- get_drafts(res, "episodes"))
  expect_length(drf, 0)

})

cli::test_that_cli("Draft episodes are reported and added episodes ignored", {

  reset_episodes(res)
  set_episodes(res, "introduction.Rmd", write = TRUE)
  expect_snapshot(drf <- get_drafts(res, "episodes"))
  expect_equal(fs::path_file(drf), "new.Rmd", ignore_attr = TRUE)

})


cli::test_that_cli("No draft episodes reports all episodes published", {

  move_episode("new.Rmd", 2, write = TRUE, path = res)
  expect_snapshot(drf <- get_drafts(res, "episodes"))
  expect_length(drf, 0)

})


