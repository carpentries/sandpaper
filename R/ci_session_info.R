#' Report session information to the user
#'
#' This function is used in continuous integration to report the packages used
#' in building the site and pull requests
#'
#' @return Nothing, used entirely for side-effect
#' @keywords internal
ci_session_info <- function() {
  has_session_info <- requireNamespace("sessioninfo", quietly = TRUE)
  if (has_session_info) {
    op <- options()
    on.exit(options(op))
    options(width = 100)
    cli::cli_rule("Time Built")
    pkg_tim <- function(p) {
      paste(format(c(p, "sandpaper"))[1], utils::packageDescription(p)$Packaged)
    }
    status <- vapply(c("sandpaper", "pegboard", "varnish", "tinkr"), pkg_tim, character(1))
    cli::cli_bullets(status)
    cli::cli_rule("Session Information")
    print(sessioninfo::platform_info())
    cli::cli_rule("Package Information")
    print(sessioninfo::package_info("sandpaper", dependencies = TRUE))
  } else {
    cli::cli_alert_danger("The sessioninfo package is needed for this function to work")
  }
  invisible()
}
