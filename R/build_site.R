#' Wrapper for site builder
#'
#' @note this assumes that the markdown files have already been built and will
#' not work otherwise
#' @inheritParams build_lesson
#' @param slug The slug for the file to preview in RStudio.
#'   If this is `NULL`, the preview will default to the home page. If you have
#'   an episode whose slug is 01-introduction, then setting `slug =
#'   "01-introduction"` will allow RStudio to open the preview window to the
#'   right page. 
#' @keywords internal
build_site <- function(path = ".", quiet = !interactive(), preview = TRUE, override = list(), slug = NULL) {
  # step 2: build the package site
  pkg <- pkgdown::as_pkgdown(path_site(path), override = override)
  # NOTE: This is a kludge to prevent pkgdown from displaying a bunch of noise
  #       if the user asks for quiet. 
  if (quiet) {
    f <- file()
    on.exit({
      sink()
      close(f)
    }, add = TRUE)
    sink(f)
  }
  pkgdown::init_site(pkg)
  episodes <- get_markdown_files()
  n <- length(episodes)
  if (!quiet && requireNamespace("cli", quietly = TRUE)) {
    cli::cli_rule(cli::style_bold("Scanning episodes"))
  }
  for (i in seq_along(episodes)) {
    build_episode_html(
      path_md      = episodes[i],
      page_back    = if (i > 1) episodes[i - 1] else "index.md",
      page_forward = if (i < n) episodes[i + 1] else "index.md",
      pkg          = pkg, 
      quiet        = quiet
    )
  }
  fs::dir_walk(
    fs::path(pkg$src_path, "built"), 
    function(d) copy_assets(d, pkg$dst_path),
    all = TRUE
  )
  if (!quiet && requireNamespace("cli", quietly = TRUE)) {
    cli::cli_rule(cli::style_bold("Creating Schedule"))
  }
  build_home(pkg, quiet = quiet)
  out <- if (is.null(slug)) "index.html" else paste0(slug, ".html")
  pkgdown::preview_site(pkg, "/", preview = preview)
  if (!quiet) {
    dst <- fs::path_rel(path = pkg$dst_path, start = path)
    message("\nOutput created: ", fs::path(pkg$dst_path, out))
  }
}
