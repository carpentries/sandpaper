test_that("check_pandoc emits nothing by default", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_silent(check_pandoc())
  suppressMessages(expect_message(check_pandoc(quiet = FALSE), "pandoc found"))
})

test_that("check_pandoc throws a message about installation", {
  skip_if(rstudioapi::isAvailable())
  skip_if_not(rmarkdown::pandoc_available())

  expect_error(check_pandoc(pv = "42"), 
    "{sandpaper} requires pandoc version 42 or higher", fixed = TRUE)

  expect_error(check_pandoc(pv = "42"), 
    "Please visit <https://pandoc.org/installing.html>", fixed = TRUE)
})

test_that("check_pandoc throws a message about installation for RStudio", {
  skip_if_not(rstudioapi::isAvailable())
  skip_if_not(rmarkdown::pandoc_available())

  expect_error(check_pandoc(pv = "42", rv = "94"), 
    "{sandpaper} requires pandoc version 42 or higher", fixed = TRUE)

  expect_error(check_pandoc(pv = "42", rv = "94"), 
    "Please update your version of RStudio Desktop to version 94 or higher", fixed = TRUE)

})
