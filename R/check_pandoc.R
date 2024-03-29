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
#' @keywords internal
#' @examples
#' # NOTE: this is an internal function, so there is no guarantee that the usage
#' # will remain the same across time. This is merely for demonstration purposes
#' # only.
#'
#' # Check for pandoc ----------------------
#' asNamespace("sandpaper")$check_pandoc(quiet = FALSE)
#'
#' # Message emitted when pandoc cannot be found --------
#' try(asNamespace("sandpaper")$check_pandoc(quiet = FALSE, pv = "999"))
check_pandoc <- function(quiet = TRUE, pv = "2.11", rv = "1.4") {
  # Does pandoc exist?
  pan <- rmarkdown::find_pandoc()
  is_test <- identical(Sys.getenv("TESTTHAT"), "true")
  pandir <- if (!is_test) pan$dir else "[path masked for testing]"
  panver <- if (!is_test) pan$version else "[version masked for testing]"
  rs_url <- "https://posit.co/download/rstudio-desktop/#download"
  pd_url <- "https://pandoc.org/installing.html"
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
    # This avoids spurious warnings in R > "4.3.0"
    # See <https://bugs.r-project.org/show_bug.cgi?id=18548>
    if (pan$version > "0") {
      pan_msg <- "You have pandoc version {.field {panver}} in {.file {pandir}}"
    } else {
      pan_msg <- "You do not have pandoc installed on your PATH"
    }
    if (Sys.getenv("RSTUDIO", "0") == "1") {
      # catch error for tests
      rs_ver <- tryCatch(rstudioapi::getVersion(), error = function(e) "0.99")
      if (rs_ver < rv) {
        install_msg <- paste(
          "Please update your version of RStudio Desktop to version",
          "{.field {rv}} or higher: {.url {rs_url}}"
        )
      } else {
        # RStudio version 1.4 comes with pandoc 2.11.4, so this should not be
        # possible.
        install_msg <- "Please visit {.url {pd_url}} to install the latest version."
      }
    } else {
      install_msg <- "Please visit {.url {pd_url}} to install the latest version."
    }

    thm <- cli::cli_div(theme = sandpaper_cli_theme())
    on.exit(cli::cli_end(thm), add = TRUE)
    cli::cli_alert_warning(msg)
    cli::cli_alert_danger(pan_msg)
    cli::cli_alert(install_msg, class = "alert-suggestion")
    stop("Incorrect pandoc version", call. = FALSE)
  }
}
