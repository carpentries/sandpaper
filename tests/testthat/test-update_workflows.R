tmp <- fs::file_temp()
fs::dir_create(tmp)
init_source_path(tmp)
ls_file <- function(i) fs::path_file(fs::dir_ls(i, all = TRUE))
update_github_workflows(tmp, quiet = TRUE)
fs::file_delete(fs::path(tmp, ".github", "workflows", "sandpaper-main.yaml"))
fs::file_create(fs::path(tmp, ".github", "workflows", "no-remove.yml"))
fs::file_create(fs::path(tmp, ".github", "workflows", "deleteme.yaml"))
gert::git_add(".github", repo = tmp)
gert::git_commit_all("first", repo = tmp)
withr::defer(fs::dir_delete(tmp))

cli::test_that_cli("github workflows can be fetched", {

  fs::file_create(fs::path(tmp, ".github", "workflows", "deleteme.yaml"))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))

  suppressMessages({
    expect_snapshot(update_github_workflows(tmp, clean = "*.yaml"))
  })

  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "sandpaper-main.yaml")))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "sandpaper-version.txt")))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "no-remove.yml")))

  expect_false(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))
})

cli::test_that_cli("github workflows can be updated", {

  fs::dir_delete(fs::path(tmp, ".github"))
  expect_silent(update_github_workflows(tmp, quiet = TRUE))
  gert::git_add("*", repo = tmp)
  gert::git_commit("second", repo = tmp)
  sm <- fs::path(tmp, ".github", "workflows", "sandpaper-main.yaml")
  l <- readLines(sm)
  writeLines(c("# HELLO!!!!", l), sm)
  expect_equal(readLines(sm, n = 1), "# HELLO!!!!")
  gert::git_add("*", repo = tmp)
  gert::git_commit("third", repo = tmp)
  suppressMessages({
    expect_snapshot(update_github_workflows(tmp, "sandpaper-main.yaml"))
  })
  expect_failure(expect_equal(readLines(sm, n = 1), "# HELLO!!!!"))

})

test_that("github workflows are recognized as up-to-date", {

  writeLines("0.0.0.8000", fs::path(tmp, ".github", "workflows", "sandpaper-version.txt"))
  gert::git_add("*", repo = tmp)
  gert::git_commit("last", repo = tmp)
  suppressMessages({
    expect_snapshot(update_github_workflows(tmp))
  })

  files_we_need <- system.file("workflows", package = "sandpaper")
  files_we_need <- c(fs::path_file(fs::dir_ls(files_we_need)), "sandpaper-version.txt")

  expect_setequal(
    ls_file(fs::path(tmp, ".github", "workflows")), 
    files_we_need
  )
  expect_equal(
    readLines(fs::path(tmp, ".github", "workflows", "sandpaper-version.txt")),
    as.character(utils::packageVersion("sandpaper"))
  )

})

test_that("nothing happens when the versions are aligned", {
  gert::git_add("*", repo = tmp)
  gert::git_commit("last", repo = tmp)
  suppressMessages({
    expect_snapshot(update_github_workflows(tmp, overwrite = FALSE))
  })
  suppressMessages({
    expect_snapshot(update_github_workflows(tmp))
  })
})
