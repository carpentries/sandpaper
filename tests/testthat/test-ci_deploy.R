res <- restore_fixture()
the_remote <- gert::git_remote_list(repo = res)
remote_name <- "sandpaper-local"

mask_output <- function(output, repo, remote) {
  output <- gsub(repo, "[repo mask]", output, fixed = TRUE)
  output <- gsub(remote, "[remote mask]", output, fixed = TRUE)
  output <- gsub("[0-9a-f]{7,}", "[sha mask]", output)
  no <- grepl("^Time", output)   | # no timestamps
    grepl("^Author", output)     | # no author
    grepl("^ ", output)            # no specific files
  output[!no]
}

test_that("ci_deploy() will deploy once", {

  skip_if_not(has_git())
  skip_if_not(rmarkdown::pandoc_available("2.11"))

  out1 <- capture.output({
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name)
  })
  expect_snapshot(mask_output(out1, res, the_remote$url))
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

  skip_if_not(has_git())
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  # The built directory does _not_ exist right now
  expect_false(fs::dir_exists(path_built(res)))

  out2 <- capture.output({suppressMessages({expect_message(
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name),
    "nothing to commit!"
  )})})
  expect_snapshot(mask_output(out2, res, the_remote$url))
  md_log   <- gert::git_log("MD", repo = res)
  site_log <- gert::git_log("SITE", repo = res)
  expect_equal(nrow(md_log), 2)
  expect_equal(nrow(site_log), 2)

})

test_that("bundle_pr_artifacts() can record diffs", {

  skip("still working on this test")

  # built worktree
  del_md <- git_worktree_setup(res, fs::path(res, "site", "built"), 
    branch = "MD", remote = remote_name
  )
  # ------------ site worktree
  del_site <- git_worktree_setup(res, fs::path(res, "site", "docs"),
    branch = "SITE", remote = remote_name
  )
})

