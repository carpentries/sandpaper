#' Wrapper for site builder
#'
#' @note this assumes that the markdown files have already been built and will
#' not work otherwise
#' @inheritParams build_lesson
#' @keywords internal
build_site <- function(path = ".", quiet = !interactive(), preview = TRUE, override = list()) {
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
  pkgdown::preview_site(pkg, "/", preview = preview)
}
