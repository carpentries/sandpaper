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
  # step 1: check pandoc
  check_pandoc(quiet)
  # step 2: build the package site
  pkg <- pkgdown::as_pkgdown(path_site(path), override = override)
  built_path <- fs::path(pkg$src_path, "built")
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

  db <- get_built_db(fs::path(built_path, "md5sum.txt"))
  db <- db[!grepl("(index|README|CONTRIBUTING)[.]md", db$built), , drop = FALSE]
  # Find all the episodes and get their range
  er <- range(grep("episodes/", db$file, fixed = TRUE))

  # Absolute paths for pandoc
  abs_md  <- fs::path(path, db$built)
  abs_src <- fs::path(path, db$file)

  # comparison function to test if a within a range of 2 b numbers
  `%w%` <- function(a, b) a >= b[[1]] && a <= b[[2]]
  page_location <- function(i, abs_md, er) {
    if (!i %w% er) {
      return(c(back = "index.md", forward = "index.md", progress = ""))
    }
    back <- if (i > er[1]) abs_md[i - 1] else "index.md"
    fwd  <- if (i < er[2]) abs_md[i + 1] else "index.md"
    pct  <- sprintf("%1.0f", (i - er[1])/(er[2] - er[1]) * 100)
    c(back = back, forward = fwd, progress = pct)
  }

  if (!quiet && requireNamespace("cli", quietly = TRUE)) {
    cli::cli_rule(cli::style_bold("Scanning episodes"))
  }

  if (is.null(slug)) {
    out <- "index.html"
    files_to_render <- seq_along(db$built)
  } else {
    out <- paste0(slug, ".html")
    files_to_render <- which(get_slug(db$built) == slug)
  }
  out <- if (is.null(slug)) "index.html" else paste0(slug, ".html")
  for (i in files_to_render) {
    location <- page_location(i, abs_md, er)
    build_episode_html(
      path_md      = abs_md[i],
      path_src     = abs_src[i],
      page_back    = location["back"],
      page_forward = location["forward"],
      page_progress = location["progress"],
      pkg          = pkg,
      quiet        = quiet
    )
  }

  fs::dir_walk(built_path, function(d) copy_assets(d, pkg$dst_path), all = TRUE)
  if (!quiet && requireNamespace("cli", quietly = TRUE)) {
    cli::cli_rule(cli::style_bold("Creating Schedule"))
  }
  build_home(pkg, quiet = quiet)
  pkgdown::preview_site(pkg, "/", preview = preview)
  if (!quiet) {
    dst <- fs::path_rel(path = pkg$dst_path, start = path)
    pth <- if (identical(Sys.getenv("TESTTHAT"), "true")) "[masked]" else pkg$dst_path
    message("\nOutput created: ", fs::path(pth, out))
  }
}
