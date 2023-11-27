local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$meta$template$params$lang,
    .local_envir = scope
  )
  add_varnish_translations()
}

add_varnish_translations <- function() {
  menu_translations <- list(
    keypoints = tr_("Key Points"),
    see_aio = tr_("See all in one page")
  )
  learner_globals$set("translate", menu_translations)
  instructor_globals$set("translate", menu_tranlsations)
}
