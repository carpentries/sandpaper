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

  suppressMessages({
  out1 <- capture.output({
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name)
  })
  })
  expected <- expand.grid(
    c("refs/heads", "refs/remotes/sandpaper-local"),
    c("main", "MD", "SITE")
  )
  expect_true(any(grepl("::group::Add worktree for sandpaper-local/MD in site/built", out1)))
  expect_true(any(grepl("::endgroup::", out1)))
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
  expect_true(gert::git_branch_exists("MD", local = TRUE, repo = res))
  expect_true(gert::git_branch_exists("SITE", local = TRUE, repo = res))
  gert::git_branch_delete("MD", repo = res)
  gert::git_branch_delete("SITE", repo = res)
  expect_false(gert::git_branch_exists("MD", local = TRUE, repo = res))
  expect_false(gert::git_branch_exists("SITE", local = TRUE, repo = res))
  # The built directory does _not_ exist right now
  expect_false(fs::dir_exists(path_built(res)))

  out2 <- capture.output({suppressMessages({expect_message(
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name),
    "nothing to commit on MD!"
  )})})
  # the built directory is cleaned up afterwards
  expect_false(fs::dir_exists(path_built(res)))

  # The branches exist and nothing new has been committed to the MD branch.
  expect_true(gert::git_branch_exists("MD", local = TRUE, repo = res))
  expect_true(gert::git_branch_exists("SITE", local = TRUE, repo = res))
  md_log   <- gert::git_log("MD", repo = res)
  expect_equal(nrow(md_log), 2)

})

