test_that("markdown sources can be built without fail", {
  
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)
  create_episode("second-episode", path = tmp)
  expect_warning(s <- get_episodes(tmp), "set_episodes")
  set_episodes(tmp, s, write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)
  # The episodes should be the only things in the directory
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(e), s)
   

  # It's noisy at first
  suppressMessages({
  expect_output(build_markdown(res, quiet = FALSE), "ordinary text without R code")
  })
  
  # No artifacts should be present in the directory
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(e), s)
  # The artifacts are present in the built directory
  b <- c(
    # Generated markdown files
    fs::path_ext_set(s, "md"), 
    "CODE_OF_CONDUCT.md", 
    "LICENSE.md", 
    "Setup.md", 
    # Folders
    "data", 
    "fig",
    "files"
  )
  a <- fs::dir_ls(fs::path(tmp, "site", "built"))
  expect_equal(fs::path_file(a), b)
  b <- c(
    b[seq(length(s) + 3)], # Files without folders
    # Generated figures
    paste0(fs::path_ext_remove(s), "-pyramid-1.png")
  )
  a <- fs::dir_ls(fs::path(tmp, "site", "built"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(a), b)

  # see helper-hash.R
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_equal(h1, h2, ignore_attr = TRUE)

  # Output is not commented
  built  <- get_markdown_files(res)
  ep     <- trimws(readLines(built[[1]]))
  ep     <- ep[ep != ""]
  outid  <- grep("[1]", ep, fixed = TRUE)
  output <- ep[outid[1]]
  fence  <- ep[outid[1] - 1]
  expect_match(output, "^\\[1\\]")
  expect_match(fence, "^[`]{3}[{]\\.output[}]")

  # But will not built if things are not changed
  expect_silent(build_markdown(res))
  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))
  expect_silent(build_markdown(res))

})
