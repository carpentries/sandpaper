tmp <- fs::file_temp()
fs::dir_create(tmp)
init_source_path(tmp)
ls_file <- function(i) fs::path_file(fs::dir_ls(i, all = TRUE))
withr::defer(fs::dir_delete(tmp))

test_that("github workflows can be fetched", {

  skip_if_offline()
  # default a bare git repo
  expect_equal(ls_file(tmp), ".git")
  
  suppressMessages({
    fetch_github_workflows(tmp, "sandpaper-main.yaml")
  })

  expect_equal(ls_file(tmp), c(".Rbuildignore", ".git", ".github"))
  expect_equal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    "sandpaper-main.yaml"
  )

})

test_that("github workflows can be updated", {

  skip_if_offline()

  sm <- fs::path(tmp, ".github", "workflows", "sandpaper-main.yaml")
  l <- readLines(sm)
  writeLines(c("# HELLO!!!!", l), sm)
  expect_equal(readLines(sm, n = 1), "# HELLO!!!!")
  suppressMessages({
    fetch_github_workflows(tmp, "sandpaper-main.yaml")
  })
  expect_failure(expect_equal(readLines(sm, n = 1), "# HELLO!!!!"))
  

})

test_that("github workflows can be added", {

  skip_if_offline()

  suppressMessages({
    fetch_github_workflows(tmp)
  })

  files_we_need <- eval(formals(fetch_github_workflows)$files)

  expect_equal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    sort(files_we_need)
  )

})
