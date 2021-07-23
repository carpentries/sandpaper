#' Check the existence of pandoc
#'
#' This function adds context to [rmarkdown::pandoc_available()] and provides
#' an error message directing the user to download the latest version of pandoc
#' or RStudio Desktop. 
#' 
#' @param quiet if `TRUE`, no message will be emitted, otherwise the pandoc
#'    version and path will be sent as a message (stderr) to the screen.
#' @param pv the minimum pandoc version
#' @param rv the minimum rstudio version (if available)
#' @noRd
check_pandoc <- function(quiet = TRUE, pv = "2.11", rv = "1.4") {
  # Does pandoc exist?
  pan <- rmarkdown::find_pandoc()
  is_test <- identical(Sys.getenv("TESTTHAT"), "true")
  pandir <- if (!is_test) pan$dir else "[path masked for testing]"
  panver <- if (!is_test) pan$version else "[version masked for testing]"
  if (rmarkdown::pandoc_available(pv)) {
    if (!quiet) {
      thm <- cli::cli_div(theme = sandpaper_cli_theme())
      cli::cli_alert_success("pandoc found")
      cli::cli_text("\u00a0\u00a0version : {.field {panver}}")
      cli::cli_text("\u00a0\u00a0path\u00a0\u00a0\u00a0   : {.file {pandir}}")
      cli::cli_end(thm)
    }
  } else {
    # Are we in an RStudio session?
    msg <- "{.pkg sandpaper} requires pandoc version {.field {pv}} or higher."
    if (pan$version > 0) {
      pan_msg <- "You have pandoc version {.field {panver}} in {.file {pandir}}"
    } else {
      pan_msg <- "You do not have pandoc installed on your PATH"
    }
    if (Sys.getenv("RSTUDIO", "0") == "1") {
      rs_ver <- rstudioapi::getVersion()
      if (rs_ver < rv) {
        install_msg <- paste(
          "Please update your version of RStudio Desktop to version", 
          "{.field {rv}} or higher:",
          "{.url https://www.rstudio.com/products/rstudio/download/#download}"
        )
      } else {
        # RStudio version 1.4 comes with pandoc 2.11.4, so this should not be
        # possible.
        install_msg <- paste("Please visit {.url https://pandoc.org/installing.html}",
          "to install the latest version.")
      }
    } else {
      install_msg <- paste("Please visit {.url https://pandoc.org/installing.html}",
        "to install the latest version.")
    }

    thm <- cli::cli_div(theme = sandpaper_cli_theme())
    on.exit(cli::cli_end(thm), add = TRUE)
    cli::cli_alert_warning(msg)
    cli::cli_alert_danger(pan_msg)
    cli::cli_alert(install_msg, class = "alert-suggestion")
    stop("Incorrect pandoc version", call. = FALSE)
  }
}
