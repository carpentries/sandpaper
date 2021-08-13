tmp <- fs::file_temp()
fs::dir_create(tmp)
init_source_path(tmp)
ls_file <- function(i) fs::path_file(fs::dir_ls(i, all = TRUE))
withr::defer(fs::dir_delete(tmp))

test_that("github workflows can be fetched", {

  # default a bare git repo
  expect_setequal(ls_file(tmp), ".git")
  
  suppressMessages({
    update_github_workflows(tmp, "sandpaper-main.yaml")
  })

  expect_setequal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    c("sandpaper-main.yaml", "sandpaper-version.txt")
  )

})

test_that("github workflows can be updated", {

  sm <- fs::path(tmp, ".github", "workflows", "sandpaper-main.yaml")
  l <- readLines(sm)
  writeLines(c("# HELLO!!!!", l), sm)
  expect_equal(readLines(sm, n = 1), "# HELLO!!!!")
  suppressMessages({
    update_github_workflows(tmp, "sandpaper-main.yaml")
  })
  expect_failure(expect_equal(readLines(sm, n = 1), "# HELLO!!!!"))

})

test_that("github workflows can be added", {

  suppressMessages({
    update_github_workflows(tmp)
  })

  files_we_need <- system.file("workflows", package = "sandpaper")
  files_we_need <- c(fs::path_file(fs::dir_ls(files_we_need)), "sandpaper-version.txt")

  expect_setequal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    files_we_need
  )

})
