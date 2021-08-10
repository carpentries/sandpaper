res <- restore_fixture()
the_remote <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"
nu_branch <- "landpaper-socal"
temp_tree <- fs::file_temp(pattern = "worktree")
fs::dir_create(temp_tree)
withr::defer(fs::dir_delete(temp_tree))

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
  make_branch(res, branch = nu_branch, checkout = TRUE)
  withr::defer(clean_branch(res, nu_branch))

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

test_that("We can create worktrees", {

  tree_one <- fs::path(temp_tree, "one")
  tree_two <- fs::path(temp_tree, "two")
  expect_false(fs::dir_exists(tree_one))
  expect_false(fs::dir_exists(tree_two))
  withr::with_dir(res, { expect_output({
    del_tree_one <- git_worktree_setup(res, 
      dest_dir = tree_one, 
      branch = "tree-one", 
      remote = remote_name
    )
  }, "Branch 'tree-one' set up to track remote branch 'tree-one' from 'sandpaper-local'")
  })

  withr::with_dir(res, { expect_output({
    del_tree_two <- git_worktree_setup(res, 
      dest_dir = tree_two, 
      branch = "tree-two", 
      remote = remote_name,
      throwaway = TRUE
    )
  }, "Preparing worktree (detached HEAD", fixed = TRUE)
  })
  expect_true(fs::dir_exists(tree_one))
  expect_true(fs::dir_exists(tree_two))
  expect_output(eval(del_tree_one), "git worktree remove .+?one$")
  expect_output(eval(del_tree_two), "git worktree remove .+?two$")
  expect_false(fs::dir_exists(tree_one))
  expect_false(fs::dir_exists(tree_two))
})
