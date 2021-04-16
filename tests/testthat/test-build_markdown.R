# setup test fixture
tmpdir <- fs::file_temp()
fs::dir_create(tmpdir)
tmp <- res <- fs::path(tmpdir, "lesson-example")
withr::defer(fs::dir_delete(tmp))

test_that("markdown sources can be built without fail", {
  
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)
  create_episode("second-episode", path = tmp)
  instruct <- fs::path(tmp, "instructors", "pyramid.md")
  writeLines(c(
    "---",
    "title: Pyramid",
    "---\n",
    "One of the best albums by MJQ"
   ),
    con = instruct
  )
  expect_warning(s <- get_episodes(tmp), "set_episodes")
  set_episodes(tmp, s, write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)
  # The episodes should be the only things in the directory
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(e), s)

  # Accidentally rendered html live in their parent folders
  rmarkdown::render(instruct, quiet = TRUE)
  expect_true(fs::file_exists(fs::path_ext_set(instruct, "html"))) 

  # It's noisy at first
  suppressMessages({
  expect_output(build_markdown(res, quiet = FALSE), "ordinary text without R code")
  })

  # # Accidentaly rendered HTML is removed before building
  expect_false(fs::file_exists(fs::path_ext_set(instruct, "html")))
  
})


test_that("markdown sources can be rebuilt without fail", {
  
  # no building needed
  expect_silent(build_markdown(res, quiet = FALSE))
  
  # everything rebuilt
  suppressMessages({
  expect_output(build_markdown(res, quiet = FALSE, rebuild = TRUE), "ordinary text without R code")
  })
})

test_that("Artifacts are accounted for", {

  s <- get_episodes(tmp)
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
    "files",
    "index.md",
    "instructor-notes.md",
    "learner-profiles.md",
    "md5sum.txt",
    "pyramid.md"
  )
  a <- fs::dir_ls(fs::path(tmp, "site", "built"))
  expect_equal(fs::path_file(a), b)
  b <- c(
    # Generated markdown files
    fs::path_ext_set(s, "md"), 
    "CODE_OF_CONDUCT.md", 
    "LICENSE.md", 
    "Setup.md", 
    # Generated figures
    paste0(fs::path_ext_remove(s), "-rendered-pyramid-1.png"),
    "index.md",
    "instructor-notes.md",
    "learner-profiles.md",
    "md5sum.txt",
    "pyramid.md"
  )
  a <- fs::dir_ls(fs::path(tmp, "site", "built"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(a), b)

})

test_that("Hashes are correct", {
  # see helper-hash.R
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_equal(h1, h2, ignore_attr = TRUE)

})

test_that("Output is not commented", {
  # Output is not commented
  built  <- get_markdown_files(res)
  ep     <- trimws(readLines(built[[1]]))
  ep     <- ep[ep != ""]
  outid  <- grep("[1]", ep, fixed = TRUE)
  output <- ep[outid[1]]
  fence  <- ep[outid[1] - 1]
  expect_match(output, "^\\[1\\]")
  expect_match(fence, "^[`]{3}[{]\\.output[}]")

})

test_that("Markdown rendering does not happen if content is not changed", {
  expect_silent(build_markdown(res))
  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))
  expect_silent(build_markdown(res))
})

test_that("Removing source removes built", {
  # Removing files will result in the markdown files being removed
  e2 <- fs::path(res, "episodes", "02-second-episode.Rmd")
  built_path <- path_built(res)
  fs::file_delete(e2)
  reset_episodes(res)
  set_episodes(res, "01-introduction.Rmd", write = TRUE)
  build_markdown(res)
#  h1 <- expect_hashed(res, "01-introduction.Rmd")
  expect_length(get_figs(res, "01-introduction"), 1)

  # The second episode should not exist
  expect_false(fs::file_exists(e2))
  expect_false(fs::file_exists(fs::path(built_path, "02-second-episode.md")))

  # The figures for the second episode should not exist either
  expect_length(get_figs(res, "02-second-episode"), 0)
})

test_that("Removing partially matching slugs will not have side-effects", {
  built_path <- path_built(res)
  
  fs::file_delete(fs::path(res, "instructors", "pyramid.md"))
  build_markdown(res)
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  expect_length(get_figs(res, "01-introduction"), 1)

  # The deleted file should be properly removed
  expect_false(fs::file_exists(fs::path(built_path, "pyramid.md")))

  # The image should still exist
  pyramid_fig <- fs::path(built_path, "fig", "01-introduction-rendered-pyramid-1.png")
  expect_true(fs::file_exists(pyramid_fig))
  
})
