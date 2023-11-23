local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$meta$template$params$lang,
    .local_envir = scope
  )
}

section_init <- function(
  pkg, depth, override = list(), .frame = parent.frame()) {
  pkg <- pkgdown::as_pkgdown(pkg, override = override)

  rstudio_save_all()
  local_envvar_pkgdown(pkg, .frame)
  local_options_link(pkg, depth = depth, .frame = .frame)

  pkg
}

