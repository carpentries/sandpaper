res <- restore_fixture()


test_that("lesson validation does not need to build the lesson", {

  (res <- validate_lesson(res, heading = TRUE)) %>% 
    expect_message("Validating Headings") %>%
    expect_message("Validating Fenced Divs") %>%
    expect_message("Validating Internal Links and Images") 
  expect_type(res, "list")
  expect_named(res, c("links", "divs", "headings"))
  expect_s3_class(res$links, "data.frame")
  expect_s3_class(res$divs, "data.frame")
  expect_s3_class(res$headings, "data.frame")

})

