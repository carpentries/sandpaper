{
tmp <- res <- restore_fixture()
suppressMessages({
  create_episode("outroduction", path = res, open = FALSE)
})
outro <- fs::path(res, "episodes", "outroduction.Rmd")
fs::file_move(outro, fs::path_ext_set(outro, "md"))

# NOTE: make sure that filenames do not clash at the moment... they will.
lt <- fs::file_create(fs::path(tmp, "learners", c("learner-test.md")))
it <- fs::file_create(fs::path(tmp, "instructors", c("test1.md", "test2.md")))
pt <- fs::file_create(fs::path(tmp, "profiles", c("profileA.md", "profileB.md")))
eps <- c("introduction.Rmd", "outroduction.md")
reset_episodes(res)
}

cli::test_that_cli("get_dropdown works as expected with messages", {

  expect_error(get_dropdown(res), "folder") # folder missing with no default
  expect_snapshot(s <- get_dropdown(res, "episodes"))
  expect_equal(s, eps)
}, configs = "plain")

test_that("episodes can be set with the output of get_episodes()", {

  suppressMessages(s <- get_episodes(res))
  set_episodes(res, s, write = TRUE)
  expect_silent(s <- get_episodes(res))
  expect_equal(s, eps)

})

test_that("get_episodes() works with trim = FALSE", {

  expect_silent(s <- get_episodes(res, trim = FALSE))
  expect_equal(basename(s), eps)
  expect_failure(expect_equal(s, eps))

})

test_that("get_episodes() works in the right order", {

  expect_silent(s <- get_episodes(res))
  set_episodes(res, rev(s), write = TRUE)
  expect_equal(get_episodes(res), rev(eps))

  expect_silent(s <- get_episodes(res, trim = FALSE))
  expect_equal(basename(s), rev(eps))
  expect_failure(expect_equal(s, rev(eps)))

})

test_that("get_learners() returns contents of the learners directory", {

  expected <- basename(as.character(fs::dir_ls(fs::path(tmp, "learners"), type = "file")))
  expect_setequal(expected, c("setup.md", "reference.md", basename(lt)))

  expect_silent(l <- get_learners(res))
  expect_equal(l, expected)
  set_learners(res, rev(l), write = TRUE)
  expect_silent(l <- get_learners(res))
  expect_equal(l, rev(expected))
  expect_silent(l <- get_learners(res, trim = FALSE))
  expect_equal(basename(l), rev(expected))
  expect_failure(expect_equal(l, rev(expected)))

})

test_that("get_instructors() returns the contents of the instructors directory", {

  expected <- basename(as.character(fs::dir_ls(fs::path(tmp, "instructors"), type = "file")))
  expect_equal(c("instructor-notes.md", basename(it)), expected)

  expect_silent(i <- get_instructors(res))
  expect_equal(i, expected)
  set_instructors(res, rev(i), write = TRUE)
  expect_silent(i <- get_instructors(res))
  expect_equal(i, rev(expected))
  expect_silent(i <- get_instructors(res, trim = FALSE))
  expect_equal(basename(i), rev(expected))
  expect_failure(expect_equal(i, rev(expected)))

})

test_that("get_profiles() returns the contents of the profiles directory", {

  expected <- basename(as.character(fs::dir_ls(fs::path(tmp, "profiles"), type = "file")))
  expect_equal(c("learner-profiles.md", basename(pt)), expected)

  expect_silent(p <- get_profiles(res))
  expect_equal(p, expected)
  set_profiles(res, rev(p), write = TRUE)
  expect_silent(p <- get_profiles(res))
  expect_equal(p, rev(expected))
  expect_silent(p <- get_profiles(res, trim = FALSE))
  expect_equal(basename(p), rev(expected))
  expect_failure(expect_equal(p, rev(expected)))

})

