test_that_pandoc <- function(desc, code, versions = "latest") {
  code <- substitute(code)
  parent <- parent.frame()
  if (!rlang::is_installed("pandoc")) {
    test <- substitute(
      testthat::test_that(desc, code)
    )
    eval(test, envir = parent)
  } else {
    lapply(versions, function(ver) {
      code2 <- substitute({
        pandoc::local_pandoc_version(ver)
        code_
      }, list(ver = ver, code_ = code))
      desc2 <- paste0(desc, " [", ver, "]")
      test <- substitute(
        testthat::test_that(desc, code),
        list(desc = desc2, code = code2)
      )
      eval(test, envir = parent)
    })
  }
}
