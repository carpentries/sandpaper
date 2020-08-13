test_that("null pipe works", {
  expect_equal(letters %||% LETTERS, letters)
  expect_equal(NULL %||% LETTERS, LETTERS)
  expect_equal(NA_character_ %||% LETTERS, NA_character_)
})


test_that("polite yaml works", {

yml <- "---
a: |
  this
  
  
  is some
   
   
   
   
    
    
    
    
   poetry?
   
   
   
   
   
   
   
   
   
b: is it?
---

This is not poetry
"

  tmp <- tempfile()
  cat(yml, file = tmp, sep = "\n")
  rl <- readLines(tmp)
  pgy <- politely_get_yaml(tmp)
  YML <- yaml::yaml.load(pgy)

  expect_true(length(rl) > length(pgy))
  expect_true(length(pgy) == 26)
  expect_true(length(YML) == 2)
  expect_named(YML, c("a", "b"))

})
