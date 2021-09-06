tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp    <- fs::path(tmpdir, "lesson-example")

withr::defer(fs::dir_delete(tmp))
expect_false(fs::dir_exists(tmp))
res <- create_lesson(tmp, open = FALSE)
create_episode("outroduction", path = res)
outro <- fs::path(res, "episodes", "02-outroduction.Rmd")
fs::file_move(outro, fs::path_ext_set(outro, "md"))

# NOTE: make sure that filenames do not clash at the moment... they will. 
lt <- fs::file_create(fs::path(tmp, "learners", c("learner-test.md")))
it <- fs::file_create(fs::path(tmp, "instructors", c("test1.md", "test2.md")))
pt <- fs::file_create(fs::path(tmp, "profiles", c("profileA.md", "profileB.md")))
eps <- c("01-introduction.Rmd", "02-outroduction.md")

test_that("get_dropdown works as expected", {
  
  expect_error(get_dropdown(res), "folder") # folder missing with no default 
  expect_warning(s <- get_dropdown(res, "episodes"), "set_episodes()", fixed = TRUE)
  expect_equal(s, eps)

})

test_that("get_episodes() works with trim = FALSE", {

  expect_warning(s <- get_episodes(res, trim = FALSE), "set_episodes()", fixed = TRUE)
  expect_equal(basename(s), eps)
  expect_failure(expect_equal(s, eps))

})

test_that("get_episodes() works in the right order", {


  expect_warning(s <- get_episodes(res), "set_episodes()", fixed = TRUE)
  set_episodes(res, rev(s), write = TRUE)
  expect_equal(get_episodes(res), rev(eps))
  s <- get_episodes(res, trim = FALSE)
  expect_equal(basename(s), rev(eps))
  expect_failure(expect_equal(s, rev(eps)))
  

})

test_that("get_learners() works as expected", {

  expected <- basename(as.character(fs::dir_ls(fs::path(tmp, "learners"))))
  expect_setequal(expected, c("setup.md", basename(lt)))

  expect_silent(l <- get_learners(res))
  expect_equal(l, expected)
  set_learners(res, rev(l), write = TRUE)
  expect_silent(l <- get_learners(res))
  expect_equal(l, rev(expected))
  expect_silent(l <- get_learners(res, trim = FALSE))
  expect_equal(basename(l), rev(expected))
  expect_failure(expect_equal(l, rev(expected)))

})

test_that("get_instructors() works as expected", {

  expected <- basename(as.character(fs::dir_ls(fs::path(tmp, "instructors"))))
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

test_that("get_profiles() works as expected", {

  expected <- basename(as.character(fs::dir_ls(fs::path(tmp, "profiles"))))
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

