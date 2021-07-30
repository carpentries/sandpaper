res <- restore_fixture()
remove_local_remote(repo = res)
rmt <- fs::file_temp(pattern = "REMOTE-")
setup_local_remote(repo = res, remote = rmt, verbose = FALSE)
the_remote <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"

test_that("A remote exists", {

  expect_equal(the_remote$name, remote_name)
  expect_true(fs::dir_exists(the_remote$url))

})

test_that("The remote has a main branch", {

  expect_true(gert::git_info(the_remote$url)$bare)

})

test_that("We can push to the remote", {

  # Create a new commit
  writeLines("hello", fs::path(res, "deleteme"))
  gert::git_add("deleteme", repo = res)
  gert::git_commit("add test file", repo = res)
  
  # Check the remote branch
  remote_ref <- "refs/remotes/sandpaper-local/main"
  expect_equal(gert::git_ahead_behind(remote_ref, repo = res)$ahead, 1L)

  # push to the remote
  gert::git_push(remote = remote_name, repo = res, verbose = FALSE)

  # check the remote branch again.
  expect_equal(gert::git_ahead_behind(remote_ref, repo = res)$ahead, 0L)

})

