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
#' @param built a character vector of newly built files or NULL. 
#' @keywords internal
build_site <- function(path = ".", quiet = !interactive(), preview = TRUE, override = list(), slug = NULL, built = NULL) {
  # step 1: check pandoc
  check_pandoc(quiet)
  this_lesson(path)
  cl <- getOption("sandpaper.links")
  on.exit(options(sandpaper.links = cl), add = TRUE)
  set_common_links(path)
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
  fs::file_create(fs::path(pkg$dst_path, ".nojekyll"))
  # future plans to reduce build times 
  rebuild_template <- TRUE || !template_check$valid()

  new_setup <- any(grepl("[/]setup[.]md", built))
  db <- get_built_db(fs::path(built_path, "md5sum.txt"))
  # filter out files that we will combine to generate
  db <- reserved_db(db)
  # Find all the episodes and get their range
  er <- range(grep("episodes/", db$file, fixed = TRUE))

  # Absolute paths for pandoc
  abs_md  <- fs::path(path, db$built)
  abs_src <- fs::path(path, db$file)

  if (!quiet) cli::cli_rule(cli::style_bold("Scanning episodes to rebuild"))

  if (is.null(slug)) {
    out <- "index.html"
    files_to_render <- seq_along(db$built)
  } else {
    out <- paste0(slug, ".html")
    files_to_render <- which(get_slug(db$built) == slug)
  }

  out <- if (is.null(slug)) "index.html" else paste0(slug, ".html")
  chapters <- abs_md[seq(er[1], er[2])]
  sidebar <- create_sidebar(c(fs::path(built_path, "index.md"), chapters))
  # shim for downlit ----------------------------------------------------------
  shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
  expected <- "5484c37e9b9c324361d775a10dea4946"
  actual   <- tools::md5sum(shimstem_file)
  if (expected == actual) {
    # evaluate the shim in our namespace
    when_done <- source(shimstem_file, local = TRUE)$value
    on.exit(eval(when_done), add = TRUE)
  }
  # end downlit shim ----------------------------------------------------------
  for (i in files_to_render) {
    location <- page_location(i, abs_md, er)
    build_episode_html(
      path_md      = abs_md[i],
      path_src     = abs_src[i],
      page_back    = location["back"],
      page_forward = location["forward"],
      page_progress = location["progress"],
      sidebar      = sidebar,
      date         = db$date[i],
      pkg          = pkg,
      quiet        = quiet
    )
  }
  # if (rebuild_template) template_check$set()

  fs::dir_walk(built_path, function(d) copy_assets(d, pkg$dst_path), all = TRUE)


  if (!quiet) cli::cli_rule(cli::style_bold("Creating learner profiles"))
  build_profiles(pkg, quiet = quiet, sidebar = sidebar)
  if (!quiet) cli::cli_rule(cli::style_bold("Creating homepage"))
  build_home(pkg, quiet = quiet, sidebar = sidebar, new_setup = new_setup, 
    next_page = abs_md[er[1]]
  )

  html_pages <- read_all_html(pkg$dst_path)
  provision_extra_template(pkg)
  on.exit(.html$clear())

  if (!quiet) cli::cli_rule(cli::style_bold("Creating keypoints summary"))
  build_keypoints(pkg, pages = html_pages, quiet = quiet)
  if (!quiet) cli::cli_rule(cli::style_bold("Creating All-in-one page"))
  build_aio(pkg, pages = html_pages, quiet = quiet)

  build_sitemap(pkg$dst_path, paths = html_pages$paths, quiet = quiet)

  pkgdown::preview_site(pkg, "/", preview = preview)

  if (!quiet) {
    dst <- fs::path_rel(path = pkg$dst_path, start = path)
    pth <- if (identical(Sys.getenv("TESTTHAT"), "true")) "[masked]" else pkg$dst_path
    message("\nOutput created: ", fs::path(pth, out))
  }
}
