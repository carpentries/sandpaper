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
  # Setup ----------------------------------------------------------------------
  #
  # Because this can be run independently of build_lesson(), we need to check
  # that pandoc exists and to provision the global lesson components if they do
  # not yet exist.
  check_pandoc(quiet)
  lsn <- this_lesson(path)
  not_overview <- !(lsn$overview && length(lsn$episodes) == 0L)
  # One feature of The Workbench is a global common links file that will be
  # appended to the markdown files before they are sent to be rendered into
  # HTML so that they will render the links correctly.
  cl <- getOption("sandpaper.links")
  on.exit(options(sandpaper.links = cl), add = TRUE)
  set_common_links(path)

  # Initialise Site ------------------------------------------------------------
  #
  # Here we provision our website using pkgdown and either initialise it if it
  # does not exist or update the CSS, HTML, and JS if it does exist.
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
  # NOTE: future plans to reduce build times
  rebuild_template <- TRUE || !template_check$valid()

  # Determining what to rebuild ------------------------------------------------
  describe_progress("Scanning episodes to rebuild", quiet = quiet)
  #
  # The 'built' object is a character vector with files that have been rebuilt.
  # new_setup <- any(grepl("[/]setup[.]md", built))
  db <- get_built_db(fs::path(built_path, "md5sum.txt"))
  # filter out files that we will combine to generate
  db <- reserved_db(db)
  if (not_overview) {
    # Find all the episodes and get their range
    er <- range(grep("episodes/", db$file, fixed = TRUE))
  } else {
    # otherwise, just give us the index for all files
    er <- seq_along(db$file)
  }
  # Get absolute paths for pandoc to understand
  abs_md <- fs::path(path, db$built)
  abs_src <- fs::path(path, db$file)
  if (not_overview) {
    chapters <- abs_md[seq(er[1], er[2])]
  } else {
    chapters <- character(0)
  }
  # If we are only processing one file, then the output should be that one file
  if (is.null(slug)) {
    out <- "index.html"
    files_to_render <- seq_along(db$built)
  } else {
    out <- paste0(slug, ".html")
    files_to_render <- which(get_slug(db$built) == slug)
  }

  # Rebuilding Episodes and generated files ------------------------------------
  # Get percentages from the syllabus table
  if (not_overview) {
    pct <- get_syllabus(path, questions = TRUE)$percents
    names(pct) <- db$file[er[1]:er[2]]
  } else {
    pct <- character(0)
  }
  # ------------------------ shim for downlit ----------------------------
  # Bypass certain downlit functions that produce unintented effects such
  # as linking function documentation.
  shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
  expected <- "230853fec984d1a0e5766d3da79f1cea"
  actual   <- tools::md5sum(shimstem_file)
  if (expected == actual) {
    # evaluate the shim in our namespace
    when_done <- source(shimstem_file, local = TRUE)$value
    # restore the original functions on exit
    on.exit(eval(when_done), add = TRUE)
  }
  # ------------------------ end downlit shim ----------------------------
  for (i in files_to_render) {
    location <- page_location(i, abs_md, er)
    build_episode_html(
      path_md       = abs_md[i],
      path_src      = abs_src[i],
      page_back     = location["back"],
      page_forward  = location["forward"],
      page_progress = pct[db$file[i]],
      date          = db$date[i],
      pkg           = pkg,
      quiet         = quiet
    )
  }
  # if (rebuild_template) template_check$set()

  fs::dir_walk(built_path, function(d) copy_assets(d, pkg$dst_path), all = TRUE)

  describe_progress("Creating 404 page", quiet = quiet)
  build_404(pkg, quiet = quiet)

  # Combined pages -------------------------------------------------------------
  #
  # There are two pages that are the result of source file combinations:
  #
  # 1. learner profiles which concatenates the files in the profiles/ folder
  describe_progress("Creating learner profiles", quiet = quiet)
  build_profiles(pkg, quiet = quiet)
  #
  # 2. home page which concatenates index.md and learners/setup.md
  describe_progress("Creating homepage", quiet = quiet)
  build_home(pkg, quiet = quiet, next_page = abs_md[er[1]])

  # Generated content ----------------------------------------------------------
  #
  # In this part of the code, we use existing content to generate pages that the
  # user does not have to modify or create. To prepare for this, we do two
  # things:
  #
  # 1. read in all of the HTML
  html_pages <- read_all_html(pkg$dst_path)
  # 2. provision the template pages for extra pages, storing them in the `.html`
  #    global variable.
  provision_extra_template(pkg)
  on.exit(.html$clear(), add = TRUE)
  #
  # The reason for pre-processing the template extra pages is that rendering
  # this page via pkgdown is costly as pkgdown has to do a read -> write -> read
  # -> modify loop in order to generate a single page. Because we are using the
  # same template, modifying only a few variables, it is easier for us to create
  # a pre-processed template where we can have variables that we can replace for
  # use.

  # Once we have the pre-processed templates and HTML content, we can pass these
  # to our aggregator functions:
  if (not_overview) {
    describe_progress("Creating keypoints summary", quiet = quiet)
    build_keypoints(pkg, pages = html_pages, quiet = quiet)

    describe_progress("Creating All-in-one page", quiet = quiet)
    build_aio(pkg, pages = html_pages, quiet = quiet)

    describe_progress("Creating Images page", quiet = quiet)
    build_images(pkg, pages = html_pages, quiet = quiet)
  }
  describe_progress("Creating Instructor Notes", quiet = quiet)
  build_instructor_notes(pkg, pages = html_pages, built = built, quiet = quiet)

  # At the end, a sitemap is created with our aggregated pages.
  build_sitemap(pkg$dst_path, paths = html_pages$paths, quiet = quiet)

  pkgdown::preview_site(pkg, "/", preview = preview)

  if (!quiet) {
    dst <- fs::path_rel(path = pkg$dst_path, start = path)
    pth <- if (identical(Sys.getenv("TESTTHAT"), "true")) "[masked]" else pkg$dst_path
    message("\nOutput created: ", fs::path(pth, out))
  }
}
