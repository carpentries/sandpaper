test_that("null pipe works", {
  expect_equal(letters %||% LETTERS, letters)
  expect_equal(NULL %||% LETTERS, LETTERS)
  expect_equal(NA_character_ %||% LETTERS, NA_character_)
})

cli::test_that_cli("polite yaml throws a message when there is no yaml", {
  
  withr::local_file(tmp <- tempfile())
  cat("# A header\n\nbut no yaml :/\n", file = tmp)
  expect_message(politely_get_yaml(tmp), "No yaml header found in the first 10 lines")

})


test_that("polite yaml works", {

yaml <- "---
a: |
  this
  
  
  is some
   
   
   
   
    
    
    
    
   poetry?
   
   
   
   
   
   
   
   
   
b: is it?
---

This is not poetry
"

  withr::local_file(tmp <- tempfile())
  cat(yaml, file = tmp, sep = "\n")
  rl <- readLines(tmp)
  pgy <- politely_get_yaml(tmp)
  YML <- yaml::yaml.load(pgy)

  expect_true(length(rl) > length(pgy))
  expect_true(length(pgy) == 26)
  expect_true(length(YML) == 2)
  expect_named(YML, c("a", "b"))

})
