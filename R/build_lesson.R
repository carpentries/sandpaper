#' Build your lesson sitf 
#'
#' In the spirit of {hugodown}, This function will build plain markdown files
#' as a minimal R package in the `site/` folder of your {sandpaper} lesson
#' repository tagged with the hash of your file to ensure that only files that
#' have changed are rebuilt. 
#' 
#' @param path the path to your repository (defaults to your current working
#' directory)
#' @param rebuild if `TRUE`, everything will be built from scratch as if there
#' was no cache. Defaults to `FALSE`, which will only build markdown files that
#' haven't been built before. 
#' @param quiet when `TRUE`, output is supressed
#' @param preview if `TRUE`, the rendered website is opened in a new window
#' @param override options to override (e.g. building to alternative paths). 
#'   This is used internally. 
#' 
#' @return `TRUE` if it was successful, a character vector of issues if it was
#'   unsuccessful.
#' 
#' @export
#' @examples
#'
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE)
#' create_episode("first-script", path = tmp)
#' check_lesson(tmp)
#' build_lesson(tmp)
build_lesson <- function(path = ".", rebuild = FALSE, quiet = !interactive(), preview = TRUE, override = list()) {
  # step 1: build the markdown vignettes and site (if it doesn't exist)
  if (rebuild) {
    clear_site(path)
  } else {
    create_site(path)
  }

  built <- build_markdown(path = path, rebuild = rebuild, quiet = quiet)

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
  episodes <- get_markdown_files(path_built(path))
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
    fs::path(pkg$src_path, "built", "assets"), 
    function(d) copy_assets(d, pkg$dst_path),
    all = TRUE
  )
  if (!quiet && requireNamespace("cli", quietly = TRUE)) {
    cli::cli_rule(cli::style_bold("Creating Schedule"))
  }
  build_home(pkg, quiet = quiet)
  pkgdown::preview_site(pkg, "/", preview = preview)
  
} 

