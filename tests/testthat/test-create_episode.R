tmp <- res <- restore_fixture()

test_that("prefixed episodes can be created", {

  initial_episode <- fs::dir_ls(fs::path(tmp, "episodes"), glob = "*Rmd") %>%
    expect_length(1L) %>%
    expect_match("01-introduction.Rmd")

  second_episode <- create_episode("First Script", path = tmp) %>%
    expect_match("02-first-script.Rmd", fixed = TRUE)

  expect_equal(readLines(second_episode, n = 2)[[2]], "title: 'First Script'")
  expect_equal(readLines(initial_episode, n = 2)[[2]], "title: 'introduction'")

  expect_true(check_episode(initial_episode))
  expect_true(check_episode(second_episode))

})

test_that("un-prefixed episodes can be created", {

  skip_on_os("windows") # y'all ain't ready for this
  title <- "\uC548\uB155 :joy_cat: \U0001F62D KITTY"
  third_episode <- create_episode(title, make_prefix = FALSE, path = tmp) %>%
    expect_match("\uC548\uB155-\U0001F62D-kitty.Rmd", fixed = TRUE)

  expect_true(check_episode(third_episode))
  expect_equal(readLines(third_episode, n = 2)[[2]], 
    paste0("title: '", title, "'"))
})
