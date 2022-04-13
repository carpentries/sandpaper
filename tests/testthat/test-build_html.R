res <- restore_fixture()
withr::defer(clear_globals())
set_globals(res)
pkg <- pkgdown::as_pkgdown(path_site(res))
# shim for downlit ----------------------------------------------------------
shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
expected <- "5484c37e9b9c324361d775a10dea4946"
actual   <- tools::md5sum(shimstem_file)
if (expected == actual) {
  # evaluate the shim in our namespace
  when_done <- source(shimstem_file, local = TRUE)$value
  withr::defer(eval(when_done))
}
# end downlit shim ----------------------------------------------------------


test_that("[build_home()] works independently", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_output(pkgdown::init_site(pkg))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "index.html")))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "instructor", "index.html")))

  built_dir <- fs::path(pkg$src_path, "built")
  fs::dir_create(built_dir)
  fs::file_copy(fs::path(res, "index.md"), built_dir)
  fs::file_copy(fs::path(res, "learners", "setup.md"), built_dir)
  build_home(pkg, quiet = TRUE, new_setup = TRUE,
    next_page = fs::path(res, "episodes", "01-introduction.Rmd")
  )
  learn_index <- fs::path(pkg$dst_path, "index.html")
  expect_true(fs::file_exists(learn_index))
  idx <- xml2::read_html(learn_index)
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//main/section[@id='setup'])"))
  instruct_index <- fs::path(pkg$dst_path, "instructor", "index.html")
  expect_true(fs::file_exists(instruct_index))
  idx <- xml2::read_html(instruct_index)
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//main/section[@id='setup'])"))
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//main/section[@id='schedule'])"))
})

test_that("[build_home()] learner index file is index and setup", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  learn_index <- fs::path(pkg$dst_path, "index.html")
  html <- xml2::read_html(learn_index)
  # Dropdown contains ifnromation for the sections in the setup page
  items <- xml2::xml_find_all(html, ".//div[@class='accordion-body']/ul/li")
  expect_length(items, 2L)
  expect_equal(xml2::xml_text(items), c("Data Sets", "Software Setup"))

  # There are four out links to the next page
  fwd <- xml2::xml_find_all(html, ".//a[starts-with(@class, 'chapter-link')]/@href")
  expect_length(fwd, 4L)
  expect_equal(xml2::xml_text(fwd), rep("01-introduction.html", 4L))

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
  expect_length(items, 1L) 
  expect_equal(xml2::xml_text(items), c("Learner Profiles"))

  # There are four out links to the next page
  fwd <- xml2::xml_find_all(html, ".//a[starts-with(@class, 'chapter-link')]/@href")
  expect_length(fwd, 4L)
  expect_equal(xml2::xml_text(fwd), rep("../instructor/01-introduction.html", 4L))

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
  expect_length(sidelinks, 5L)
  expect_match(sidelinks[[1]], "href=[\"]..[/]profiles.html")
  expect_match(sidelinks[[2]], "Summary and Schedule")

  learn <- fs::path(pkg$dst_path, "profiles.html")
  learn <- xml2::read_html(learn)
  
  # Learner sidebar is formatted properly
  sidebar <- xml2::xml_find_all(learn, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_match(sidelinks[[1]], "href=[\"]instructor[/]profiles.html")
  expect_match(sidelinks[[2]], "Summary and Setup")

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

test_that("[build_keypoints()] works independently", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "key-points.html")))
  expect_false(fs::file_exists(fs::path(pkg$dst_path, "instructor", "key-points.html")))
  build_keypoints(pkg, quiet = TRUE)
  expect_true(fs::file_exists(fs::path(pkg$dst_path, "key-points.html")))
  expect_true(fs::file_exists(fs::path(pkg$dst_path, "instructor", "key-points.html")))

})


test_that("[build_keypoints()] learner and instructor views are identical", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  instruct <- fs::path(pkg$dst_path, "instructor", "key-points.html")
  instruct <- xml2::read_html(instruct)

  # Instructor sidebar is formatted properly
  sidebar <- xml2::xml_find_all(instruct, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_length(sidelinks, 5L)
  expect_match(sidelinks[[1]], "href=[\"]..[/]key-points.html")
  expect_match(sidelinks[[2]], "Summary and Schedule")

  learn <- fs::path(pkg$dst_path, "key-points.html")
  learn <- xml2::read_html(learn)
  
  # Learner sidebar is formatted properly
  sidebar <- xml2::xml_find_all(learn, ".//div[@class='sidebar']")
  expect_length(sidebar, 1L)
  sidelinks <- as.character(xml2::xml_find_all(sidebar, ".//a"))
  expect_match(sidelinks[[1]], "href=[\"]instructor[/]key-points.html")
  expect_match(sidelinks[[2]], "Summary and Setup")

  # sections are equal
  learn_sections <- as.character(xml2::xml_find_all(learn, ".//section"))
  instruct_sections <- as.character(xml2::xml_find_all(instruct, ".//section"))
  expect_equal(learn_sections, instruct_sections)

  # the instructor metadata contains this page information
  meta <- xml2::xml_find_first(instruct, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/instructor/key-points.html")

  # the learner metadata contains this page information
  meta <- xml2::xml_find_first(learn, ".//script[@type='application/ld+json']")
  meta <- trimws(xml2::xml_text(meta))
  expect_match(meta, "lesson-example/key-points.html")
})

