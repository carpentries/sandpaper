tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp    <- fs::path(tmpdir, "lesson-example")

withr::defer(fs::dir_delete(tmp))
expect_false(fs::dir_exists(tmp))
res <- create_lesson(tmp)
create_episode("outroduction", path = res)
outro <- fs::path(res, "episodes", "02-outroduction.Rmd")
fs::file_move(outro, fs::path_ext_set(outro, "md"))
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


