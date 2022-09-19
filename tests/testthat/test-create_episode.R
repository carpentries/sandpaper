tmp <- res <- restore_fixture()

test_that("non-prefixed episodes can be created", {

  initial_episode <- fs::dir_ls(fs::path(tmp, "episodes"), glob = "*Rmd") %>%
    expect_length(1L) %>%
    expect_match("introduction.Rmd")

  second_episode <- create_episode_md("First Markdown", path = tmp) %>%
    expect_match("first-markdown.md", fixed = TRUE)

  expect_equal(get_episodes(tmp), c("introduction.Rmd", "first-markdown.md"))
  ep1 <- readLines(initial_episode)
  ep2 <- readLines(second_episode)

  expect_equal(ep1[[2]], "title: 'introduction'")
  expect_true(any(grepl("^```[{]r pyramid", ep1))) # first episode will have R Markdown
  
  expect_equal(ep2[[2]], "title: 'First Markdown'")
  expect_no_match(ep2, "^```[{]r pyramid") # second episode will not have R Markdown
  expect_no_match(ep2, "^Or you") # second episode will not have R Markdown

})

test_that("un-prefixed episodes can be created", {

  skip_on_os("windows") # y'all ain't ready for this
  title <- "\uC548\uB155 :joy_cat: \U0001F62D KITTY"
  third_episode <- create_episode_rmd(title, path = tmp) %>%
    expect_match("\uC548\uB155-\U0001F62D-kitty.Rmd", fixed = TRUE)

  expect_equal(get_episodes(tmp), c("introduction.Rmd", "first-markdown.md", "\uC548\uB155-\U0001F62D-kitty.Rmd"))
  expect_equal(readLines(third_episode, n = 2)[[2]], 
    paste0("title: '", title, "'"))
})


test_that("draft episodes can be drafted", {

  skip_on_os("windows") # y'all ain't ready for this
  draft_episode_md("ignore-me", path = tmp)
  expect_equal(get_episodes(tmp), c("introduction.Rmd", "first-markdown.md", "\uC548\uB155-\U0001F62D-kitty.Rmd"))
  draft_episode_rmd("ignore-me-in-r", path = tmp)
  expect_equal(get_episodes(tmp), c("introduction.Rmd", "first-markdown.md", "\uC548\uB155-\U0001F62D-kitty.Rmd"))

  expect_setequal(
    as.character(fs::path_file(get_drafts(tmp, message = FALSE))), 
    c("ignore-me.md", "ignore-me-in-r.Rmd"))

})


test_that("prefixed episodes can be reverted", {

  # setup: create episodes with prefixes and remove the schedule
  skip_on_os("windows") # y'all ain't ready for this
  episodes <- get_episodes(tmp)
  epathodes <- path_episodes(tmp)
  new_episodes <- sprintf("%02d-%s", seq(episodes), episodes)
  fs::file_move(fs::path(epathodes, episodes), fs::path(epathodes, new_episodes))
  reset_episodes(tmp)

  # set the schedule and test the strip_prefix info
  set_episodes(tmp, new_episodes, write = TRUE)
  expect_equal(get_episodes(tmp), new_episodes)
  expect_snapshot(strip_prefix(tmp, write = FALSE))
  
  # check that nothing has been written and then rewrite the episodes
  expect_equal(get_episodes(tmp), new_episodes)
  strip_prefix(tmp, write = TRUE)
  
  # none of the draft episodes should appear here
  expect_equal(get_episodes(tmp), episodes)

  expect_snapshot(strip_prefix(tmp, write = FALSE), transform = function(x) trimws(x))

})
