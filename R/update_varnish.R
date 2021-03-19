#nocov start

#' Update the local version of the carpentries style
#'
#' @param version if NULL, update the latest version, otherwise, this can be a
#'   version string to identify the specific version to use. 
#' @param ... arguments passed on to [utils::install.packages()]
#' @return NULL, invisibly
#' @export
#'
#' @note this requires an internet connection
update_varnish <- function(version = NULL, ...) {
  repo <- "https://carpentries.github.io/drat/"
  if (is.null(version)) {
    utils::install.packages("varnish", repos = repo, ...)
  } else {
    varn <- paste0(
      repo, "src/contrib/varnish_", version, ".tar.gz"
    )
    utils::install.packages(varn)
  }
  invisible(NULL)
}
#nocov end
