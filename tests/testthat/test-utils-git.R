res         <- restore_fixture()
the_remote  <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"
nu_branch   <- "landpaper-socal"
remote_ref  <- glue::glue("refs/remotes/sandpaper-local/{nu_branch}")
# Create our new branch for testing
make_branch(res, branch = nu_branch)
temp_tree <- fs::file_temp(pattern = "worktree")
fs::dir_create(temp_tree)
withr::defer({
  # Clean up the directory and clean up our temporary branch
  fs::dir_delete(temp_tree)
  clean_branch(res, nu_branch)
})


test_that("A remote exists", {

  expect_equal(the_remote$name, remote_name)
  expect_true(fs::dir_exists(the_remote$url))

})

test_that("The remote has a main branch", {

  expect_true(gert::git_info(the_remote$url)$bare)
  expect_equal(gert::git_info(the_remote$url)$shorthand, "main")

})

test_that("We can push to branches on the remote", {

  gert::git_branch_checkout(nu_branch, repo = res)
  withr::defer(gert::git_branch_checkout("main", repo = res))

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


test_that("We can create throwaway worktrees from existing remote branches", {

  skip_if_not(has_git())
  # the branch currently exists
  expect_true(gert::git_branch_exists(nu_branch, local = TRUE, repo = res))

  # we can delete it and it will still exist in the remote
  gert::git_branch_delete(nu_branch, repo = res)
  expect_false(gert::git_branch_exists(nu_branch, local = TRUE, repo = res))

  this_tree <- fs::path(temp_tree, "existing")
  expect_false(fs::dir_exists(this_tree))
  withr::with_dir(res, {
    expect_output({
      del_tree <- git_worktree_setup(res,
        dest_dir = this_tree,
        branch = nu_branch,
        remote = remote_name,
        throwaway = TRUE
      )
    }, "Preparing worktree \\(detached HEAD [0-9a-f]{7}\\)")
  })

  withr::with_dir(this_tree, {
    expect_true(fs::file_exists("deleteme"))
  })
  expect_true(fs::dir_exists(this_tree))
  expect_output(eval(del_tree), "existing")
  expect_false(fs::dir_exists(this_tree))
  expect_false(gert::git_branch_exists(nu_branch, local = TRUE, repo = res))

})

test_that("We can create worktrees from existing remote branches", {

  skip_if_not(has_git())
  # The branch does not exist locally
  expect_false(gert::git_branch_exists(nu_branch, local = TRUE, repo = res))

  this_tree <- fs::path(temp_tree, "in-remote")
  expect_false(fs::dir_exists(this_tree))
  withr::with_dir(res, {
    expect_output({
      del_tree <- git_worktree_setup(res,
        dest_dir = this_tree,
        branch = nu_branch,
        remote = remote_name
      )
    }, "Branch 'landpaper-socal' set up to track remote branch")
  })
  withr::with_dir(this_tree, {
    expect_true(fs::file_exists("deleteme"))
  })
  # The worktree exists until we remove it
  expect_true(fs::dir_exists(this_tree))
  expect_output(eval(del_tree), "in-remote")
  expect_false(fs::dir_exists(this_tree))

  # But the branch remains because we created it
  expect_true(gert::git_branch_exists(nu_branch, local = TRUE, repo = res))

})

test_that("We can create worktrees from random branches", {

  skip_if_not(has_git())

  tree_one <- fs::path(temp_tree, "one")
  tree_two <- fs::path(temp_tree, "two")
  expect_false(fs::dir_exists(tree_one))
  expect_false(fs::dir_exists(tree_two))
  withr::with_dir(res, { 
    expect_output({
      del_tree_one <- git_worktree_setup(res, 
        dest_dir = tree_one, 
        branch = "tree-one", 
        remote = remote_name
      )
    }, "Branch 'tree-one' set up to track remote branch 'tree-one' from 'sandpaper-local'")
  })
  # The worktree exists until we remove it
  expect_true(fs::dir_exists(tree_one))
  expect_output(eval(del_tree_one), "one")
  expect_false(fs::dir_exists(tree_one))
  # The branch remains, so we need to clean it up
  expect_true(gert::git_branch_exists("tree-one", local = TRUE, repo = res))
  clean_branch(res, "tree-one")

  withr::with_dir(res, { 
    expect_output({
      del_tree_two <- git_worktree_setup(res, 
        dest_dir = tree_two, 
        branch = "tree-two", 
        remote = remote_name,
        throwaway = TRUE
      )
    }, "Preparing worktree \\(detached HEAD [0-9a-f]{7}\\)")
  })
  # The worktree exists until we remove it
  expect_true(fs::dir_exists(tree_two))
  expect_output(eval(del_tree_two), "two")
  expect_false(fs::dir_exists(tree_two))
  # even though we worked on a detached HEAD copy, the branch exists because
  # we created it here.
  expect_true(gert::git_branch_exists("tree-two", local = TRUE, repo = res))
  clean_branch(res, "tree-two")
})
