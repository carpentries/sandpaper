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

  expect_true(fs::file_exists(fs::path(tmp, ".github", "workflows", "workflows-version.txt")))
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

  writeLines("0.0.0.8000", fs::path(tmp, ".github", "workflows", "workflows-version.txt"))
  gert::git_add("*", repo = tmp)
  gert::git_commit("last", repo = tmp)
  suppressMessages({
    expect_snapshot(update_github_workflows(tmp))
  })

  releases_url <- "https://api.github.com/repos/carpentries/workbench-workflows/releases/latest"
  releases_json <- jsonlite::fromJSON(releases_url)
  latest_version_tag <- releases_json$tag_name
  latest_version <- package_version(gsub("^v", "", latest_version_tag))
  zip_url <- releases_json$zipball_url

  temp_zip <- fs::file_temp(ext = ".zip")
  httr::GET(zip_url, httr::write_disk(temp_zip, overwrite = TRUE))
  temp_dir <- fs::dir_create(fs::file_temp())
  utils::unzip(temp_zip, exdir = temp_dir)

  files_we_need <- fs::dir_ls(temp_dir, recurse = TRUE, regexp = ".*workflows/.*\\.(md|yaml)$")
  new_files <- character(length(files_we_need))
  names(new_files) <- basename(files_we_need)

  expect_setequal(
    ls_file(fs::path(tmp, ".github", "workflows")),
    names(new_files)
  )
  expect_equal(
    readLines(fs::path(tmp, ".github", "workflows", "workflows-version.txt")),
    as.character(latest_version)
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
