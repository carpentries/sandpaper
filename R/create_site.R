create_site <- function(path) {

  chk <- check_site_rendered(path)

  if (!isTRUE(chk$site)) fs::dir_create(path_site(path))

  if (!isTRUE(chk$readme)) create_site_readme(path)

  if (!isTRUE(chk$built)) fs::dir_create(path_built(path))

  if (!isTRUE(chk$description)) {
    fs::file_create(fs::path(path_site(path), "DESCRIPTION"))
    create_description(path)
  }

  if (!isTRUE(chk$config)) {
    yaml <- create_pkgdown_yaml(path)
    write_pkgdown_yaml(yaml, path)
  }
}
