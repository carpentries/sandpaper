
test_that("check_pandoc emits nothing by default", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_silent(check_pandoc())
  suppressMessages(expect_message(check_pandoc(quiet = FALSE), "pandoc found"))
})

cli::test_that_cli("check_pandoc() throws a message about installation", {
  skip_if(rstudioapi::isAvailable())
  skip_if_not(rmarkdown::pandoc_available())

  expect_snapshot(expect_error(check_pandoc(pv = "42"), "Incorrect pandoc version"))
})

cli::test_that_cli("check_pandoc throws a message about installation for RStudio", {
  skip_if_not(rmarkdown::pandoc_available())

  withr::with_envvar(c(RSTUDIO = "1"), {
    expect_snapshot({
      expect_error(check_pandoc(pv = "42", rv = "94"), 
        "Incorrect pandoc version", 
        fixed = TRUE)
    })
})

})
