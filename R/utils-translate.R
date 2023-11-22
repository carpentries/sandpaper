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

rstudio_save_all <- function() {
  if (
    rlang::is_installed("rstudioapi") &&
      rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }
}

local_options_link <- function(pkg, depth, .frame = parent.frame()) {
  article_index <- article_index(pkg)
  rdname <- get_rdname(pkg$topics)
  topic_index <- unlist(invert_index(
    purrr::set_names(pkg$topics$alias, rdname)))

  withr::local_options(
    list(
      downlit.package = pkg$package,
      downlit.article_index = article_index,
      downlit.topic_index = topic_index,
      downlit.article_path = paste0(up_path(depth), "articles/"),
      downlit.topic_path = paste0(up_path(depth), "reference/")
    ),
    .local_envir = .frame
  )
}

article_index <- function(pkg) {
  purrr::set_names(
    fs::path_rel(pkg$vignettes$file_out, "articles"),
    fs::path_file(pkg$vignettes$name)
  )
}

get_rdname <- function(topics) {
  gsub("\\.[Rr]d$", "", topics$file_in)
}

invert_index <- function(x) {
  stopifnot(is.list(x))

  if (length(x) == 0)
    return(list())

  key <- rep(names(x), purrr::map_int(x, length))
  val <- unlist(x, use.names = FALSE)

  split(key, val)
}

up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}
