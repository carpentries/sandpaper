cli::test_that_cli("ci_session_info() produces output", {
  
  suppressMessages({
  expect_output(ci_session_info(), "sandpaper") %>%
    expect_message("Package Information")
  })

})
