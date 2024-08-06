#' Global Options
#'
#' this is some documentation about options
#' 
#' 
#'
#'@details 
#' 
#' ```
#' option("sandpaper.show_draft" = TRUE)
#' option("sandpaper.links" = NULL)
#' option("sandpaper.use_renv" = FALSE)
#' option("sandpaper.package_cache_trigger" = FALSE)
#' option("sandpaper.test_fixture" = NULL)
#' ```
#'
#' As of 2022-02-22, there are several options that are used in sandpaper that
#' may be manipulated by the user. This set may change in the future, but here
#' are the description of these options and how they are set on startup:
#'
#' ### sandpaper.show_draft
#'
#' **Default: `TRUE`** This is for user messages. If `TRUE`, a message about
#' episodes in draft status (i.e. episodes that are in the folder, but not in
#' the schedule) will be printed with `get_drafts()`. Setting this option to
#' `FALSE` will turn off this feature.
#'
#' ### sandpaper.links
#' 
#' **Default: `NULL`** This option provides a way to override the default place
#' for links in your sandpaper lesson. If it is NULL and there is a file called
#' `links.md` at the top of the repository, this will be appended to the bottom
#' of each page before it is rendered to HTML.
#'
#' ### sandpaper.use_renv
#'
#' **Default: variable** This option should not be modified by the user. It
#' determines if `{renv}` should be used locally for R-based lessons. It is set
#' by [use_package_cache()] and unset by [no_package_cache()]. If a local user
#' has never consented to using `{renv}` previously, then it defaults to `FALSE`,
#' but if `{renv}` has previously been used, it will be `TRUE`.
#'
#' ### sandpaper.package_cache_trigger
#'
#' **Default: FALSE locally/TRUE on GitHub** this tells R Markdown lessons to
#' rebuild everything if the `{renv}` lockfile changes. 
#' 
#' ### sandpaper.test_fixture 
#'
#' **Default: NULL** This is ONLY for internal use for testing interactive
#' components non-interactively and for setting `{renv}` to behave correctly while
#' testing. 
#'
#' @name sandpaper.options
NULL
