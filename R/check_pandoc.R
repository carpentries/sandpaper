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
  if (rmarkdown::pandoc_available(pv)) {
    if (!quiet) {
      message("pandoc found")
      message("version : ", pan$version)
      message("path    : ", shQuote(pan$dir))
    }
  } else {
    # Are we in an RStudio session?
    msg <- paste("{sandpaper} requires pandoc version", pv, "or higher.")
    if (pan$version > 0) {
      pan_msg <- paste("You have pandoc version", pan$version, "in", shQuote(pan$dir))
    }
    if (rstudioapi::isAvailable()) {
      rs_ver <- rstudioapi::getVersion()
      if (rs_ver < rv) {
        install_msg <- paste(
          "Please update your version of RStudio Desktop to version", 
          rv, 
          "or higher:",
          "<https://www.rstudio.com/products/rstudio/download/#download>"
        )
      } else {
        # RStudio version 1.4 comes with pandoc 2.11.4, so this should not be
        # possible.
        install_msg <- paste("Please visit <https://pandoc.org/installing.html>",
          "to install the latest version.")
      }
    } else {
      install_msg <- paste("Please visit <https://pandoc.org/installing.html>",
        "to install the latest version.")
    }
    msg <- paste0(msg, "\n", pan_msg, "\n\n", install_msg)
    stop(msg, call. = FALSE)
  }
}
