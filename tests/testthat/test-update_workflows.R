tmp <- fs::file_temp()
fs::dir_create(tmp)
init_source_path(tmp)
ls_file <- function(i) fs::path_file(fs::dir_ls(i, all = TRUE))
update_github_workflows(tmp, quiet = TRUE)
fs::file_create(fs::path(tmp, ".github", "workflows", "no-remove.yml"))
fs::file_create(fs::path(tmp, ".github", "workflows", "deleteme.yaml"))
gert::git_add(".github", repo = tmp)
gert::git_commit_all("first", repo = tmp)
withr::defer(fs::dir_delete(tmp))

cli::test_that_cli("github workflows can be fetched", {

  fs::file_create(fs::path(tmp, ".github", "workflows", "deleteme.yaml"))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))

  suppressMessages({
    expect_snapshot(update_github_workflows(tmp))
  })

  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "sandpaper-version.txt")))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "no-remove.yml")))

  expect_false(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))
})

test_that("setting clean = NULL will preserve old workflows", {

  fs::file_create(fs::path(tmp, ".github", "workflows", "deleteme.yaml"))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))
  suppressMessages({
    update_github_workflows(tmp, clean = NULL)
  })

  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))
  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "no-remove.yml")))

  suppressMessages({
    update_github_workflows(tmp)
  })

  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "no-remove.yml")))
  expect_false(fs::file_exists(fs::path(tmp, ".github", "workflows", "deleteme.yaml")))

})

cli::test_that_cli("github workflows can be updated", {

  fs::dir_delete(fs::path(tmp, ".github"))
  expect_silent(update_github_workflows(tmp, quiet = TRUE))

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
