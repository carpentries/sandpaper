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
    usethis::with_project(tmp, fetch_github_workflows("sandpaper-main.yaml"))
  })

  expect_equal(ls_file(tmp), c(".Rbuildignore", ".git", ".github"))
  expect_equal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    "sandpaper-main.yaml"
  )

})

test_that("github workflows can be added", {

  suppressMessages({
    usethis::with_project(tmp, fetch_github_workflows())
  })

  files_we_need <- eval(formals(fetch_github_workflows)$files)

  expect_equal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    sort(files_we_need)
  )

})
