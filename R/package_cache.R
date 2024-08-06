#' Give Consent to Use Package Cache
#'
#' @description
#'
#' These functions explicitly gives \pkg{sandpaper} permission to use \pkg{renv}
#' to create a package cache for this and future lessons. There are two states
#' that you can use:
#'
#'   1. `use_package_cache()`: Gives explicit permission to set up and use the
#'      package cache with your lesson.
#'   2. `no_package_cache()`: Temporarily suspends permission to use the package
#'      cache with your lesson, regardless if it was previously given.
#'
#' Once you have a package cache defined, you can use changes in the lockfile to
#' trigger rebuilds of the lesson. To do this, you can use:
#'
#'   - `package_cache_trigger(TRUE)`
#'
#' The above function is best used in conjunction with [update_cache()]
#'
#'
#' @details
#'
#' ## Background
#'
#' By default, \pkg{sandpaper} will happily build your lesson using the packages
#' available in your default R library, but this can be undesirable for a couple
#' of reasons:
#'
#' 1. You may have a different version of a lesson package that is used on the
#'    lesson website, which may result in strange errors, warnings, or incorrect
#'    output.
#' 2. You might be very cautious about updating any components of your current
#'    R infrastructure because your work depends on you having the correct
#'    package versions installed.
#'
#' To alleviate these concerns, \pkg{sandpaper} uses the \pkg{renv} package to
#' generate a lesson-specific library that has package versions pinned until
#' the lesson authors choose to update them. This is designed to be
#' minimally-invasive, using the packages you already have and downloading from
#' external repositories only when necessary.
#'
#' ## What if I have used \pkg{renv} before?
#'
#' If you have used \pkg{renv} in the past, then there is no need to give
#' consent to use the cache.
#'
#' ## How do I turn off the feature temporarily?
#'
#' To turn off the feature you can use `no_package_cache()`. \pkg{sandpaper}
#' will respect this option when building your lesson and will use your global
#' library instead.
#'
#' ## I have used \pkg{renv} before; how do I turn it off before sandpaper loads?
#'
#' You can set `options(sandpaper.use_renv = FALSE)` before loading `{sandpaper}`.
#'
#' @param prompt if `TRUE` (default when interactive), a prompt for consent
#'   giving information about the proposed modifications will appear on the
#'   screen asking for the user to choose to apply the changes or not.
#' @param quiet if `TRUE`, messages will not be issued unless `prompt = TRUE`.
#'   This defaults to the opposite of `prompt`.
#'
#' @export
#' @rdname package_cache
#' @return nothing. this is used for its side-effect
#' @seealso [manage_deps()] and [update_cache()] for managing the requirements
#'   inside the package cache.
#' @examples
#' if (!getOption("sandpaper.use_renv") && interactive()) {
#'   # The first time you set up `{renv}`, you will need permission
#'   use_package_cache(prompt = TRUE)
#'   # The package cache trigger is FALSE, by default
#'   default <- package_cache_trigger()
#'   # You can set this to `TRUE` when you update packages with `update_cache()`
#'   package_cache_trigger(TRUE)
#'   # set the trigger back to its former state
#'   package_cache_trigger(default)
#' }
#'
#' if (getOption("sandpaper.use_renv") && interactive()) {
#'   # If you have previously used `{renv}`, permission is implied
#'   use_package_cache(prompt = TRUE)
#'
#'   # You can temporarily turn this off
#'   no_package_cache()
#'   getOption("sandpaper.use_renv") # should be FALSE
#'   use_package_cache(prompt = TRUE)
#' }
use_package_cache <- function(prompt = interactive(), quiet = !prompt) {
  consent_ok <- "Consent to use package cache provided"
  if (getOption("sandpaper.use_renv") || !prompt) {
    options(sandpaper.use_renv = TRUE)
    msg <- try_use_renv(force = TRUE)
    consent_provided <- if (is_testing()) TRUE else grepl("nothing to do", msg)
    if (consent_provided)  {
      info <- consent_ok
    } else {
      info <- "{consent_ok}\n{.emph {msg}}"
    }
    if (!quiet) {
      cli::cli_alert_info(info)
    }
    return(invisible())
  }
  msg <- try_use_renv()
  if (getOption("sandpaper.use_renv")) {
    if (!quiet) {
      cli::cli_alert_info("Consent for {.pkg renv} provided---consent for package cache implied.")
    }
    return(invisible())
  }
  #nocov start
  options <- message_package_cache(msg)
  x <- utils::menu(options)
  if (x == 1) {
    options(sandpaper.use_renv = TRUE)
    msg <- try_use_renv(force = TRUE)
    if (!quiet) {
      cli::cli_alert_info("{consent_ok}\n{.emph {msg}}")
    }
  } else {
    options(sandpaper.use_renv = FALSE)
    options(renv.consent = FALSE)
  }
  cli::cli_end()
  return(invisible())
  #nocov end
}

#' @rdname package_cache
#' @export
no_package_cache <- function() {
  cli::cli_alert_info("Consent for package cache revoked. Use {.fn use_package_cache} to undo.")
  options("sandpaper.use_renv" = FALSE)
}

#' @rdname package_cache
#' @param rebuild The new value of the `sandpaper.package_cache_trigger` global
#'   option. Setting this to `TRUE` will result in _all materials_ being
#'   rebuilt when new records enter the package cache lockfile even if no
#'   source files have changed. Setting this to `FALSE` will return this to the
#'   default state, which is to rebuld only if the source files have changed.
#'   The default is `NULL`, which does nothing.
#' @return the value of `getOption("sandpaper.package_cache_trigger")` or
#'    `FALSE`, if it is unset.
#' @export
package_cache_trigger <- function(rebuild = NULL) {
  if (isTRUE(rebuild) || isFALSE(rebuild)) {
    options("sandpaper.package_cache_trigger" = rebuild)
  }
  return(getOption("sandpaper.package_cache_trigger", default = FALSE))
}

