res <- restore_fixture()
the_remote <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"
has_git <- Sys.which("git") != ""

test_that("ci_deploy() will deploy once", {

  skip_if_not(has_git)
  skip_if_not(rmarkdown::pandoc_available("2.11"))

  ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name)
  expected <- expand.grid(
    c("refs/heads", "refs/remotes/sandpaper-local"),
    c("main", "MD", "SITE")
  )
  expected <- apply(expected, 1, paste, collapse = "/")
  expect_setequal(gert::git_info(res)$reflist, expected)
  md_log   <- gert::git_log("MD", repo = res)
  site_log <- gert::git_log("SITE", repo = res)
  expect_equal(nrow(gert::git_log(repo = res)), 1)
  expect_equal(nrow(md_log), 2)
  expect_equal(nrow(site_log), 2)
  expect_match(md_log$message[2], "MD branch")
  expect_match(site_log$message[2], "SITE branch")


})

test_that("ci_deploy() will fetch sources from upstream", {

  skip_if_not(has_git)
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # The built directory does _not_ exist right now
  expect_false(fs::dir_exists(path_built(res)))

  suppressMessages({expect_message(
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name),
    "nothing to commit!"
  )})
  md_log   <- gert::git_log("MD", repo = res)
  site_log <- gert::git_log("SITE", repo = res)
  expect_equal(nrow(md_log), 2)
  skip("Behavior of the site worktree needs investigating")
  expect_equal(nrow(site_log), 2)

})

