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

  skip_on_cran()
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

  skip_on_cran()
  skip_if_not(has_git())
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_true(gert::git_branch_exists("MD", local = TRUE, repo = res))
  expect_true(gert::git_branch_exists("SITE", local = TRUE, repo = res))

  # Add an extra file that should be removed to the site -----------------------
  #
  # check out the branch
  gert::git_branch_checkout("SITE", repo = res)
  withr::defer(gert::git_branch_checkout("main", repo = res))

  # create the file
  writeLines("hello", fs::path(res, "deleteme"))
  gert::git_add("deleteme", repo = res)
  # commit, push and checkout main
  gert::git_commit("add test file", repo = res)
  gert::git_push(remote = "sandpaper-local", repo = res, verbose = FALSE)
  gert::git_branch_checkout("main", repo = res)

  # remove the branches and ensure they are deleted
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

  withr::defer(gert::git_branch_checkout("main", repo = res))
  gert::git_branch_checkout("SITE", repo = res)
  expect_true(file.exists(file.path(res, "deleteme")))

})


test_that("404 page root will be lesson URL", {
  skip_on_cran()
  skip_if_not(has_git())
  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # in the main branch, this file does not exist
  expect_false(file.exists(file.path(res, "404.html")))

  # setup for test inside of site branch
  withr::defer(gert::git_branch_checkout("main", repo = res))
  gert::git_branch_checkout("SITE", repo = res)

  # in the site branch, it does exist
  expect_true(file.exists(file.path(res, "404.html")))

  html <- xml2::read_html(file.path(res, "404.html"))

  # find the stylesheet node: expect that it has https link
  stysh <- xml2::xml_find_first(html, "//head/link[@rel='stylesheet']")
  url <- xml2::xml_attr(stysh, "href")
  parsed <- xml2::url_parse(url)

  # test that it has the form of https://[server]/lesson-example/[stylesheet]
  expect_equal(parsed[["scheme"]], "https")
  expect_false(parsed[["server"]] == "")
  expect_true(startsWith(parsed[["path"]], "/lesson-example"))

  # test that the menu items all have same form
  navbar <- xml2::xml_find_all(html, "//nav//li/a")
  hrefs <- xml2::xml_attr(navbar, "href")
  parsed <- xml2::url_parse(hrefs)
  expect_equal(unique(parsed[["scheme"]]), "https")
  expect_false(unique(parsed[["server"]]) == "")
  expect_true(all(startsWith(parsed[["path"]], "/lesson-example")))

  # test that the sidebar items are all appopriate
  # (with exception of the instructor view toggle)
  sidebar_links <- "//div[@class='accordion-body']//a[not(text()='Instructor View')]"
  sidebar <- xml2::xml_find_all(html, sidebar_links)
  hrefs <- xml2::xml_attr(sidebar, "href")
  parsed <- xml2::url_parse(hrefs)

  expect_equal(unique(parsed[["scheme"]]), "https")
  expect_false(unique(parsed[["server"]]) == "")
  expect_true(all(startsWith(parsed[["path"]], "/lesson-example")))
  # The index page should be one of the pages that we are inspecting here
  # This directly addresses https://github.com/carpentries/sandpaper/issues/498
  expect_true(any(parsed[["path"]] == "/lesson-example/index.html"))


})


test_that("ci_deploy() will do a full rebuild", {

  skip_on_cran()
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

  suppressMessages({
  out2 <- capture.output({
    ci_deploy(res, md_branch = "MD", site_branch = "SITE", remote = remote_name, reset = TRUE)
  })
  })
  # the built directory is cleaned up afterwards
  expect_false(fs::dir_exists(path_built(res)))

  # The branches exist and nothing new has been committed to the MD branch.
  expect_true(gert::git_branch_exists("MD", local = TRUE, repo = res))
  expect_true(gert::git_branch_exists("SITE", local = TRUE, repo = res))

  # We can confirm that the deleteme file does not exist because it was removed
  # by rebuild = TRUE
  withr::defer(gert::git_branch_checkout("main", repo = res))
  gert::git_branch_checkout("SITE", repo = res)
  expect_false(file.exists(file.path(res, "deleteme")))

})

