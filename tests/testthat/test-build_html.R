res <- restore_fixture()
withr::defer(clear_globals())
idx <- readLines(fs::path(res, "index.md"))
writeLines(c(idx[1], "title: '**TEST** title'", idx[-1]),
  fs::path(res, "index.md"))
set_globals(res)
pkg <- pkgdown::as_pkgdown(path_site(res))
# shim for downlit ----------------------------------------------------------
shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
expected <- "230853fec984d1a0e5766d3da79f1cea"
actual   <- tools::md5sum(shimstem_file)
M1 <- sprintf("SHIM FILE: %s", shimstem_file)
M2 <- sprintf("--------- CONTENTS ----------\n%s\n-----------------------------",
    paste(readLines(shimstem_file), collapse = "\n"))
if (expected == actual) {
  # evaluate the shim in our namespace
  when_done <- source(shimstem_file, local = TRUE)$value
  withr::defer(eval(when_done))
} else {
  stop(sprintf("shim broken\nexpected: %s\nactual:   %s\n%s\n%s",
      expected, actual, M1, M2))
}
# end downlit shim ----------------------------------------------------------

test_that("(#536) SANDPAPER_SITE envvar works as expected", {

  # NOTE: this involves a bit of fenangleing because when I wrote this test
  # suite originally, I was relying on non-independent tests. That is, all the
  # tests in this particular file are not indedpendent of one another and MUST
  # be run in order.
  #
  # In order to set this up, I need to do the following:
  #
  # 1. create the temporary directory
  # 2. set up the site with `create_site()`
  # 3. initialise it with pkgdown::init()
  #
  # During each step, I want to test to make sure it behaves as expected
  # (e.g. the directories created by each step do not exist
  # until they are initialised).

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- withr::local_tempdir("site")
  withr::local_envvar(list("SANDPAPER_SITE" = tmp))

  # setting the envvar doesn't actually create the built folder
  expect_false(fs::file_exists(fs::path(tmp, "_pkgdown.yaml")))
  create_site(res)
  expect_true(fs::file_exists(fs::path(tmp, "_pkgdown.yaml")))

  # the site path should be equal to our temporary path
  dst_path <- fs::path(path_site(res), "docs")
  # NOTE: for Windows and Mac, the realised temp paths and the actual temp
  # paths will differ, so we need to do this weird relative path comparison BS
  # >:(
  site_rel <- fs::path_file(path_site(res))
  env_rel  <- fs::path_file(Sys.getenv("SANDPAPER_SITE"))
  expect_equal(site_rel, env_rel)
  rel_dst <- fs::path_join(rev(fs::path_split(dst_path)[[1]])[2:1])
  expect_equal(fs::path(env_rel, "docs"), rel_dst)
  # but it should not yet exist because we still need to initialise it
  expect_false(fs::dir_exists(dst_path))

  # the path_site() should point to our SANDAPER_SITE variable.
  new_pkg <- pkgdown::as_pkgdown(path_site(res))
  expect_equal(new_pkg$dst_path, fs::path(path_site(res), "docs"))
  expect_false(identical(pkg$dst_path, fs::path(path_site(res), "docs")))
  # When we initialise a pkgdown site, it should initialise inside of the
  # SANDPAPER_SITE envvar
  expect_output(pkgdown::init_site(new_pkg))
  expect_true(fs::dir_exists(dst_path))

  # none of the files should exist before build
  SITE_profiles_learner <- fs::path(dst_path, "profiles.html")
  SITE_profiles_instructor <- fs::path(dst_path, "instructor", "profiles.html")
  orig_profiles_learner <- fs::path(pkg$dst_path, "profiles.html")
  orig_profiles_instructor <- fs::path(pkg$dst_path, "instructor", "profiles.html")
  expect_false(fs::file_exists(SITE_profiles_learner))
  expect_false(fs::file_exists(SITE_profiles_instructor))
  expect_false(fs::file_exists(orig_profiles_learner))
  expect_false(fs::file_exists(orig_profiles_instructor))

  # after build, only the files constrolled by the SANDPAPER_SITE envvar should
  # exist, but the ones in the default site should not exist.
  build_profiles(new_pkg, quiet = TRUE)
  expect_true(fs::file_exists(SITE_profiles_learner))
  expect_true(fs::file_exists(SITE_profiles_instructor))
  expect_false(fs::file_exists(orig_profiles_learner))
  expect_false(fs::file_exists(orig_profiles_instructor))

})


test_that("[build_home()] works independently", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_output(pkgdown::init_site(pkg))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "index.html")))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "instructor", "index.html")))

  built_dir <- fs::path(pkg$src_path, "built")
  fs::dir_create(built_dir)
  fs::file_copy(fs::path(res, "index.md"), built_dir)
  fs::file_copy(fs::path(res, "learners", "setup.md"), built_dir)
  build_home(pkg, quiet = TRUE,
    next_page = fs::path(res, "episodes", "introduction.Rmd")
  )
  learn_index <- fs::path(pkg$dst_path, "index.html")
  expect_true(fs::file_exists(learn_index))
  idx <- xml2::read_html(learn_index)
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//main/section[@id='setup'])"))
  newtitle <- xml2::xml_find_first(idx, ".//span[@class='current-chapter']/*")
  expect_identical(as.character(newtitle), "<strong>TEST</strong>")
  newtitle <- xml2::xml_find_first(idx, ".//h1/*")
  expect_identical(as.character(newtitle), "<strong>TEST</strong>")

  instruct_index <- fs::path(pkg$dst_path, "instructor", "index.html")
  expect_true(fs::file_exists(instruct_index))
  idx <- xml2::read_html(instruct_index)
  newtitle <- xml2::xml_find_first(idx, ".//span[@class='current-chapter']/*")
  expect_identical(as.character(newtitle), "<strong>TEST</strong>")
  newtitle <- xml2::xml_find_first(idx, ".//h1/*")
  expect_identical(as.character(newtitle), "<strong>TEST</strong>")
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//main/section[@id='setup'])"))
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//main/section[@id='schedule'])"))
})

test_that("[build_home()] learner index file is index and setup", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  learn_index <- fs::path(pkg$dst_path, "index.html")
  html <- xml2::read_html(learn_index)
  # Dropdown contains ifnromation for the sections in the setup page
  items <- xml2::xml_find_all(html, ".//div[@class='accordion-body']/ul/li")
  expect_snapshot(writeLines(as.character(items)))

  # There are four out links to the next page
  fwd <- xml2::xml_find_all(html, ".//a[starts-with(@class, 'chapter-link')]/@href")
  expect_length(fwd, 4L)
  expect_equal(xml2::xml_text(fwd), rep("introduction.html", 4L))

  # The metadata contains this page information
  meta <- xml2::xml_find_first(html, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/index[.]html['\"]")

})

test_that("[build_home()] instructor index file is index and schedule", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  instruct_index <- fs::path(pkg$dst_path, "instructor", "index.html")
  html <- xml2::read_html(instruct_index)

  # there is only one dropdown in here and it is the common instructor linkouts
  items <- xml2::xml_find_all(html, ".//div[@class='accordion-body']/ul/li")
  expect_snapshot(writeLines(as.character(items)))

  # There are four out links to the next page
  fwd <- xml2::xml_find_all(html, ".//a[starts-with(@class, 'chapter-link')]/@href")
  expect_length(fwd, 4L)
  expect_equal(xml2::xml_text(fwd), rep("../instructor/introduction.html", 4L))

  # the metadata contains this page information
  meta <- xml2::xml_find_first(html, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/instructor/index[.]html['\"]")
})



test_that("[build_profiles()] works independently", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "profiles.html")))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "instructor", "profiles.html")))
  build_profiles(pkg, quiet = TRUE)
  expect_true(fs::file_exists(fs::path(pkg$dst_path, "profiles.html")))
  expect_true(fs::file_exists(fs::path(pkg$dst_path, "instructor", "profiles.html")))

})


test_that("[build_profiles()] learner and instructor views are identical", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  instruct <- fs::path(pkg$dst_path, "instructor", "profiles.html")
  instruct <- xml2::read_html(instruct)

  # Instructor sidebar is formatted properly
  sidebar <- xml2::xml_find_all(instruct, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  sidelinks_instructor <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_snapshot(writeLines(sidelinks_instructor))

  learn <- fs::path(pkg$dst_path, "profiles.html")
  learn <- xml2::read_html(learn)

  # Learner sidebar is formatted properly
  sidebar <- xml2::xml_find_all(learn, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks_learner <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_snapshot(writeLines(sidelinks_learner))

  # sections are equal
  learn_sections <- as.character(xml2::xml_find_all(learn, ".//section"))
  instruct_sections <- as.character(xml2::xml_find_all(instruct, ".//section"))
  expect_equal(learn_sections, instruct_sections)

  # the instructor metadata contains this page information
  meta <- xml2::xml_find_first(instruct, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/instructor/profiles.html")

  # the learner metadata contains this page information
  meta <- xml2::xml_find_first(learn, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/profiles.html")
})


