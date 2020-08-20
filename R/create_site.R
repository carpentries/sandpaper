create_site <- function(path) {
  fs::dir_create(fs::path(path, "site"))
  fs::dir_create(fs::path(path, "site", "vignettes"))

  fs::file_create(fs::path(path, "site", "DESCRIPTION"))
  fs::file_create(fs::path(path, "site", "README.md"))
  create_site_readme(path)
  check_git_user(path)
  create_description(path)
  yml <- create_pkgdown_yaml(path)
  write_pkgdown_yaml(yml, path)
}
