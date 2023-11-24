local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$meta$template$params$lang,
    .local_envir = scope
  )
}

add_varnish_translations <- function(pkg) {
  pkg$translate <- list(
    keypoints = tr_("Key Points"),
    see_aio = tr_("See all in one page")
  )
  return(pkg)
}