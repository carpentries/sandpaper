#nocov start
.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)
  delayedAssign("GITIGNORED", gitignore_items(), eval.env = ns, assign.env = ns)
  # Check for implicit `{renv}` consent. If the user has used it before, we should
  # use it in the `{sandpaper}` lesson, unless the user has explicitly told us not
  # to.
  op <- getOption("sandpaper.use_renv")
  if (is.null(op)) {
    try_use_renv()
  }
  establish_translation_vars()
  invisible()
}
#nocov end
