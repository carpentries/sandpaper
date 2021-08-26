.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)
  delayedAssign("GITIGNORED", gitignore_items(), eval.env = ns, assign.env = ns)
  options(sandpaper.use_renv = renv_has_consent())
}
