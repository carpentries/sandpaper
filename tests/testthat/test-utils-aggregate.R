test_that("read_all_html returns appropriate files", {

  tmpdir <- withr::local_tempdir()
  fs::dir_create(tmpdir)
  fs::dir_create(fs::path(tmpdir, "instructor"))
  writeLines("<p>Instructor</p>", fs::path(tmpdir, "instructor", "index.html"))
  writeLines("<p>Learner</p>", fs::path(tmpdir, "index.html"))
  res <- read_all_html(tmpdir)
  expect_named(res, c( "instructor", "learner","paths"))
  expect_length(res$paths, 2L)
  expect_s3_class(res$learner$index, "xml_document")
  expect_s3_class(res$instructor$index, "xml_document")
  expect_equal(xml2::xml_text(res$learner$index), "Learner")
  expect_equal(xml2::xml_text(res$instructor$index), "Instructor")

})



