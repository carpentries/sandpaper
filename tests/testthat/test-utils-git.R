res <- restore_fixture()
the_remote <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"
nu_branch <- "landpaper-socal"
remote_ref <- glue::glue("refs/remotes/sandpaper-local/{nu_branch}")

test_that("A remote exists", {

  expect_equal(the_remote$name, remote_name)
  expect_true(fs::dir_exists(the_remote$url))

})

test_that("The remote has a main branch", {

  expect_true(gert::git_info(the_remote$url)$bare)

})

test_that("We can push to branches on the remote", {

  # Create a new commit
  del_branch <- make_branch(res, nu_branch)
  withr::defer(clean_branch(res))

  writeLines("hello", fs::path(res, "deleteme"))
  gert::git_add("deleteme", repo = res)
  gert::git_commit("add test file", repo = res)
  
  # Check the remote branch
  expect_equal(gert::git_ahead_behind(remote_ref, repo = res)$ahead, 1L)

  # push to the remote
  gert::git_push(remote = remote_name, repo = res, verbose = FALSE)

  # check the remote branch again.
  expect_equal(gert::git_ahead_behind(remote_ref, repo = res)$ahead, 0L)

})

