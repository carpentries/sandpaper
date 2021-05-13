test_that("lessons can be created in empty directories", {

  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  wd  <- fs::path(normalizePath(getwd()))
  suppressMessages({expect_message({
    res <- create_lesson(tmp, rstudio = TRUE, open = TRUE)
  }, "Setting active project to")})
  tmp <- normalizePath(tmp)
  expect_false(wd == fs::path(normalizePath(getwd())))
  expect_equal(normalizePath(getwd()), tmp)
  # enforce that we do NOT have a master branch
  expect_false(gert::git_branch(tmp) == "master")
  expect_false(gert::git_branch_exists("master", repo = tmp))
  # enforce that our new branch matches the user's default branch (or main)
  expect_true(gert::git_branch(tmp) == sandpaper:::get_default_branch())

  # Make sure everything exists
  expect_true(check_lesson(tmp))
  expect_true(fs::dir_exists(tmp))
  expect_equal(
    politely_get_yaml(fs::path(tmp, "index.md"))[[2]], 
    "site: sandpaper::sandpaper_site"
  ) 
  expect_true(fs::dir_exists(fs::path(tmp, "site")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "data")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "files")))
  expect_true(fs::dir_exists(fs::path(tmp, "episodes", "fig")))
  expect_true(fs::dir_exists(fs::path(tmp, "instructors")))
  expect_true(fs::dir_exists(fs::path(tmp, "learners")))
  expect_true(fs::dir_exists(fs::path(tmp, "profiles")))
  expect_true(fs::file_exists(fs::path(tmp, "README.md")))
  expect_match(readLines(fs::path(tmp, "README.md"))[1], "lesson-example", fixed = TRUE) 
  expect_true(fs::file_exists(fs::path(tmp, "site", "README.md")))
  expect_true(fs::file_exists(fs::path(tmp, "site", "DESCRIPTION")))
  expect_true(fs::file_exists(fs::path(tmp, "site", "_pkgdown.yaml")))
  expect_true(fs::file_exists(fs::path(tmp, "site", "built")))
  expect_true(fs::file_exists(fs::path(tmp, "episodes", "01-introduction.Rmd")))
  expect_true(fs::file_exists(fs::path(tmp, ".gitignore")))
  expect_true(fs::file_exists(fs::path(tmp, paste0(basename(tmp), ".Rproj"))))
  expect_setequal(
    readLines(fs::path(tmp, ".gitignore")), 
    readLines(template_gitignore())
  )
  expect_setequal(
    readLines(fs::path(tmp, "episodes", "01-introduction.Rmd")), 
    readLines(template_episode())
  )
  
  expect_true(nrow(gert::git_status(repo = tmp)) == 0)

  # create a new file in the site directory
  fs::file_touch(fs::path(tmp, "site", "DESCRIPTION"))
  expect_true(nrow(gert::git_status(repo = tmp)) == 0)

  # add a new thing to gitignore
  cat("# No ticket\nticket.txt\n", file = fs::path(tmp, ".gitignore"), append = TRUE)
  expect_true(check_lesson(tmp))
  expect_true(check_episode(fs::path(tmp, "episodes", "01-introduction.Rmd")))

  
  # Ensure it is a git repo
  expect_true(fs::dir_exists(fs::path(tmp, ".git")))

  commits <- gert::git_log(repo = tmp)
  config <- gert::git_config(repo = tmp)

  expect_equal(nrow(commits), 1L)
  expect_match(commits$message[1L], "Initial commit")

  if (gert::user_is_configured()) {
    expect_match(commits$author[1L], config$value[config$name == "user.name"], fixed = TRUE)
  } else {
    expect_match(commits$author[1L], "carpenter <team@carpentries.org>", fixed = TRUE)
  }

  # Temporary configurations are not permanent
  if (gert::user_is_configured()) {
    expect_false(config$value[config$name == "user.name"] == "carpenter")
    expect_false(config$value[config$name == "user.email"] == "team@carpentries.org")
  } else {
    expect_false(length(config$value[config$name == "user.name"]) > 0)
    expect_false(length(config$value[config$name == "user.email"]) > 0)
  }

  fs::file_delete(fs::path(tmp, ".gitignore"))
    suppressMessages({
    expect_error( 
      check_lesson(tmp), 
      "There were errors with the lesson structure"
    )
    })
})

test_that("lessons cannot be created in directories that are occupied", {

  skip("needs evaluation, but not critical infrastructure tool")
  tmpdir <- fs::file_temp()
  fs::dir_create(tmpdir)
  tmp    <- fs::path(tmpdir, "lesson-example")

  withr::defer(fs::dir_delete(tmp))
  expect_false(fs::dir_exists(tmp))
  res <- create_lesson(tmp)

  # Make sure everything exists
  expect_true(fs::dir_exists(tmp))

  # This should fail
  expect_error(create_lesson(tmp), "lesson-example is not an empty directory.")

})
