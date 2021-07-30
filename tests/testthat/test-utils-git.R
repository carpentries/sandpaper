res <- restore_fixture()
the_remote <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"

test_that("A remote exists", {
  expect_equal(the_remote$name, "sandpaper-local")
  expect_true(fs::dir_exists(the_remote$url))
})

test_that("The remote has a main branch", {
  expect_true(gert::git_info(the_remote$url)$bare)
})

test_that("We can push to the remote", {
  
  remote_ref <- gert::git_remote_info(remote_name, repo = res)$head

  writeLines("hello", fs::path(res, "deleteme"))
  gert::git_add("deleteme", repo = res)
  gert::git_commit("add test file", repo = res)
  expect_equal(gert::git_ahead_behind(remote_ref, repo = res)$ahead, 1L)
  gert::git_push(remote = remote_name, repo = res, verbose = FALSE)
  expect_equal(gert::git_ahead_behind(remote_ref, repo = res)$ahead, 0L)

})

test_that("ci_deploy() will deploy once", {


  skip_if_not(rmarkdown::pandoc_available("2.11"))
  ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name)
  print(gert::git_info(res)$reflist)
  expected <- expand.grid(
    c("refs/heads", "refs/remotes/sandpaper-local"),
    c("main", "MD", "SITE")
  )
  expected <- apply(expected, 1, paste, collapse = "/")
  print(expected)
  expect_setequal(gert::git_info(res)$reflist, expected)
  md_log <- gert::git_log("MD", repo = res)
  site_log <- gert::git_log("SITE", repo = res)
  expect_equal(nrow(gert::git_log(repo = res)), 2)
  expect_equal(nrow(md_log), 2)
  expect_equal(nrow(site_log), 2)
  expect_match(md_log$message[2], "MD branch")
  expect_match(site_log$message[2], "SITE branch")


})

test_that("ci_deploy() will fetch sources from upstream", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # The built directory does _not_ exist right now
  expect_false(fs::dir_exists(path_built(res)))

  suppressMessages({expect_message(
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name),
    "nothing to commit!"
  )})
  md_log <- gert::git_log("MD", repo = res)
  site_log <- gert::git_log("SITE", repo = res)
  expect_equal(nrow(md_log), 2)
  expect_equal(nrow(site_log), 2)

})

