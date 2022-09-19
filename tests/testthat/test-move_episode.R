{
  res <- restore_fixture()
  create_episode("new", add = FALSE, path = res)
  create_episode("new too", add = FALSE, path = res)
  create_episode("new mewtwo three", add = FALSE, path = res)
  eporder <- c("introduction.Rmd", "new.Rmd", "new-mewtwo-three.Rmd", "new-too.Rmd")
  set_episodes(res, eporder, write = TRUE)
}

test_that("all episodes are present in the config file", {
  
  eps <- get_config(res)$episodes
  expect_setequal(eps, fs::path_file(get_sources(res, "episodes")))
  expect_equal(eps, eporder)

})


test_that("Errors happen with invalid position arguments", {

  expect_error(move_episode(4, 5, path = res), "position")
  suppressMessages({
  move_episode(6, 5, path = res) %>%
    expect_message("Episode index 6 is out of range") %>%
    expect_error()
  })
  expect_error(move_episode("new.Rmd", 5, path = res), "position")
  expect_error(move_episode("new.Rmd", -5, path = res), "position")

})

cli::test_that_cli("no position will trigger an interactive search", {

  expect_snapshot(tryCatch(move_episode(1, path = res), 
      error = function(e) e$message))

})

cli::test_that_cli("Episodes can be moved to a different position", {

  set_episodes(res, eporder, write = TRUE)
  expect_equal(get_episodes(res), eporder)

  expect_snapshot(move_episode("new-too.Rmd", 3, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder)

  expect_snapshot(move_episode("introduction.Rmd", 4, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder)
  
  expect_snapshot(move_episode(4, 3, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder)

  move_episode(4, 3, write = TRUE, path = res)
  expect_equal(get_episodes(res), 
    c("introduction.Rmd", "new.Rmd", "new-too.Rmd", "new-mewtwo-three.Rmd"))

  move_episode("introduction.Rmd", 4, write = TRUE, path = res)
  expect_equal(get_episodes(res), 
    c("new.Rmd", "new-too.Rmd", "new-mewtwo-three.Rmd", "introduction.Rmd"))

  move_episode("introduction.Rmd", 1, write = TRUE, path = res)
  expect_equal(get_episodes(res), 
    c("introduction.Rmd", "new.Rmd", "new-too.Rmd", "new-mewtwo-three.Rmd"))

})

cli::test_that_cli("Episodes can be moved out of position", {

  set_episodes(res, eporder, write = TRUE)
  expect_equal(get_episodes(res), eporder)

  expect_snapshot(move_episode("new-mewtwo-three.Rmd", 0, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder)

  # FALSE is equivalent to zero
  expect_snapshot(move_episode("new-mewtwo-three.Rmd", FALSE, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder)

  expect_snapshot(move_episode(3, 0, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder)

  move_episode(3, 0, write = TRUE, path = res)
  expect_equal(get_episodes(res), 
    c("introduction.Rmd", "new.Rmd", "new-too.Rmd"))

})

cli::test_that_cli("no position will trigger an interactive search", {

  expect_snapshot(tryCatch(move_episode("new-mewtwo-three.Rmd", path = res), 
      error = function(e) e$message))

})

test_that("Errors happen with invalid file arguments", {

  suppressMessages({
  move_episode(TRUE, 1, path = res) %>%
    expect_message("'TRUE' does not refer to any episode") %>%
    expect_error()
  move_episode(c("one", "two"), 1, path = res) %>%
    expect_message("Too many episodes specified: one and two.") %>%
    expect_error("file name")
  move_episode("more-more-more.Rmd", 1, path = res) %>%
    expect_error("episodes or drafts")
  })

})

cli::test_that_cli("Drafts can be added to the index", {

  set_episodes(res, eporder[-3], write = TRUE)
  expect_equal(get_episodes(res), eporder[-3])

  expect_snapshot(move_episode("new-mewtwo-three.Rmd", 1, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder[-3])

  expect_snapshot(move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder[-3])

  # true is the equivalent of the end of the list
  expect_snapshot(move_episode("new-mewtwo-three.Rmd", TRUE, write = FALSE, path = res))
  expect_equal(get_episodes(res), eporder[-3])

  expect_snapshot(move_episode("new-mewtwo-three.Rmd", 4, write = TRUE, path = res))
  expect_equal(get_episodes(res), 
    c("introduction.Rmd", "new.Rmd", "new-too.Rmd", "new-mewtwo-three.Rmd"))

})

