#' Build a single episode html file
#'
#' This is a Carpentries-specific wrapper around [pkgdown::render_page()] with
#' templates from {varnish}. This function is largely for internal use and will
#' likely change.
#'
#' @param path_md the path to the episode markdown (not RMarkdown) file
#'   (usually via [build_episode_md()]).
#' @param path_src the default is `NULL` indicating that the source file should
#'   be determined from the `sandpaper-source` entry in the yaml header. If this
#'   is not present, then this option allows you to specify that file. 
#' @param page_back the URL for the previous page
#' @param page_forward the URL for the next page
#' @param pkg a `pkgdown` object containing metadata for the site
#' @param quiet if `TRUE`, messages are not produced. Defaults to `TRUE`.
#' @param page_progress an integer between 0 and 100 indicating the rounded 
#'   percent of the page progress. Defaults to NULL.
#' @param sidebar a character vector of links to other episodes to use for the
#'   sidebar. The current episode will be replaced with an index of all the
#'   chapters in the episode.
#' @param date the date the episode was last built.
#' @return `TRUE` if the page was successful, `FALSE` otherwise.
#' @export
#' @note this function is for internal use, but exported for those who know what
#'   they are doing. 
#' @keywords internal
#' @seealso [build_episode_md()], [build_lesson()], [build_markdown()], [render_html()]
#' @examples
#' if (.Platform$OS.type == "windows") {
#'   options("sandpaper.use_renv" = FALSE)
#' }
#' if (!interactive() && getOption("sandpaper.use_renv")) {
#'   old <- renv::config$cache.symlinks()
#'   options(renv.config.cache.symlinks = FALSE)
#'   on.exit(options(renv.config.cache.symlinks = old), add = TRUE)
#' }
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE)
#' suppressMessages(set_episodes(tmp, get_episodes(tmp), write = TRUE))
#' if (rmarkdown::pandoc_available("2.11")) {
#'   # we can only build this if we have pandoc
#'   build_lesson(tmp)
#' }
#'
#' # create a new file in files
#' fun_file <- file.path(tmp, "episodes", "files", "fun.Rmd")
#' txt <- c(
#'  "---\ntitle: Fun times\n---\n\n",
#'  "# new page\n", 
#'  "This is coming from `r R.version.string`\n",
#'  "::: testimonial\n\n#### testimony!\n\nwhat\n:::\n"
#' )
#' file.create(fun_file)
#' writeLines(txt, fun_file)
#' hash <- tools::md5sum(fun_file)
#' res <- build_episode_md(fun_file, hash)
#' if (rmarkdown::pandoc_available("2.11")) {
#'   # we can only build this if we have pandoc
#'   build_episode_html(res, path_src = fun_file, 
#'     pkg = pkgdown::as_pkgdown(file.path(tmp, "site"))
#'   )
#' }
build_episode_html <- function(path_md, path_src = NULL, 
                               page_back = "index.md", page_forward = "index.md", 
                               pkg, quiet = FALSE, page_progress = NULL, 
                               sidebar = NULL, date = NULL) {
  home <- root_path(path_md)
  body <- render_html(path_md, quiet = quiet)
  nodes <- xml2::read_html(body)
  fix_nodes(nodes)
  yaml <- yaml::yaml.load(politely_get_yaml(path_md), eval.expr = FALSE)
  path_src <- if (is.null(path_src)) yaml[["sandpaper-source"]] else path_src
  title <- parse_title(yaml$title)
  if (!is.null(sidebar)) {
    this_page <- fs::path_file(fs::path_ext_set(path_md, "html"))
    to_change <- grep(paste0("[<]a href=['\"]", this_page, "['\"]"), sidebar)
    sidebar[to_change] <- create_sidebar_item(nodes, title, "current")
  }
  # shim for downlit
  shimstem_file <- system.file("pkgdown", "shim.R", package = "sandpaper")
  expected <- "5484c37e9b9c324361d775a10dea4946"
  actual   <- tools::md5sum(shimstem_file)
  if (expected == actual) {
    # evaluate the shim in our namespace
    when_done <- source(shimstem_file, local = TRUE)$value
    on.exit(eval(when_done), add = TRUE)
  }
  # end downlit shim
  this_page <- as_html(path_md, instructor = TRUE)
  pb_title <- if (page_back == "index.md") "Home" else get_trimmed_title(page_back)
  pf_title <- if (page_forward == "index.md") NULL else get_trimmed_title(page_forward)
  page_back <- as_html(page_back, instructor = TRUE)
  page_forward <- as_html(page_forward, instructor = TRUE)
  if (!is.null(sidebar)) {
    idx <- "<a href='index.html'>Summary and Schedule</a>"
    sidebar[[1]] <- create_sidebar_item(nodes, idx, 1)
  }

  json <- create_metadata_jsonld(home, 
    date = list(modified = date),
    pagetitle = title,
    url = paste0(this_metadata$get()$url, "/", this_page)
  )

  dat_instructor <- c(
    list(
      # NOTE: we can add anything we want from the YAML header in here to
      # pass on to the template.
      body         = use_instructor(nodes),
      more         = extras_menu(pkg$src_path, "instructors"),
      resources    = extras_menu(pkg$src_path, "instructors", header = FALSE),
      pagetitle    = title,
      minutes      = as.integer(yaml$teaching) + as.integer(yaml$exercises),
      file_source  = fs::path_rel(path_src, start = home),
      this_page    = fs::path_file(this_page),
      page_back    = page_back,
      back_title   = pb_title,
      page_forward = page_forward,
      forward_title = pf_title,
      progress     = page_progress,
      sidebar      = paste(sidebar, collapse = "\n"),
      updated      = date,
      json         = json,
      instructor   = TRUE
      ),
    varnish_vars()
  )

  ipath <- fs::path(pkg$dst_path, "instructor")
  if (!fs::dir_exists(ipath)) fs::dir_create(ipath)

  modified <- pkgdown::render_page(pkg, 
    "chapter",
    data = dat_instructor,
    depth = 1L,
    path = this_page,
    quiet = quiet
  )
  if (modified) {
    if (!is.null(sidebar)) {
      idx <- "<a href='index.html'>Summary and Setup</a>"
      sidebar[[1]] <- create_sidebar_item(nodes, idx, 1)
    }

    json <- create_metadata_jsonld(home, 
      date = list(modified = date),
      pagetitle = title,
      url = paste0(this_metadata$get()$url, "/", as_html(this_page))
    )

    # we only need to compute the learner page if the instructor page has
    # modified since the instructor material contains more information and thus
    # more things to modify.
    dat_learner <- modifyList(dat_instructor, 
      list(
        body = use_learner(nodes),
        more = extras_menu(pkg$src_path, "learners"),
        resources = extras_menu(pkg$src_path, "learners", header = FALSE),
        instructor = FALSE,
        page_back = fs::path_file(page_back), 
        page_forward = fs::path_file(page_forward), 
        json         = json,
        sidebar      = paste(gsub("instructor/", "", sidebar), collapse = "\n")
      )
    )
    pkgdown::render_page(pkg, 
      "chapter",
      data = dat_learner,
      depth = 0L,
      path = as_html(this_page),
      quiet = quiet
    )
  }
}

#' Build an episode to markdown
#'
#' This uses [knitr::knit()] with custom options set for the Carpentries
#' template. It runs in a separate process to avoid issues with user-specific
#' options bleeding in. 
#'
#' @param path path to the RMarkdown file
#' @param hash hash to prepend to the output. This parameter is deprecated and
#'   is effectively useless.
#' @param outdir the directory to write to
#' @param workdir the directory where the episode should be rendered
#' @param env a blank environment
#' @param quiet if `TRUE`, output is suppressed, default is `FALSE` to show 
#'   {knitr} output.
#' @return the path to the output, invisibly
#' @keywords internal
#' @export
#' @note this function is for internal use, but exported for those who know what
#'   they are doing. 
#' @seealso [render_html()], [build_episode_html()]
#' @examples
#' if (.Platform$OS.type == "windows") {
#'   options("sandpaper.use_renv" = FALSE)
#' }
#' if (!interactive() && getOption("sandpaper.use_renv")) {
#'   old <- renv::config$cache.symlinks()
#'   options(renv.config.cache.symlinks = FALSE)
#'   on.exit(options(renv.config.cache.symlinks = old), add = TRUE)
#' }
#' fun_dir <- tempfile()
#' dir.create(fs::path(fun_dir, "episodes"), recursive = TRUE)
#' fun_file <- file.path(fun_dir, "episodes", "fun.Rmd")
#' file.create(fun_file)
#' txt <- c(
#'  "---\ntitle: Fun times\n---\n\n",
#'  "# new page\n", 
#'  "This is coming from `r R.version.string`"
#' )
#' writeLines(txt, fun_file)
#' res <- build_episode_md(fun_file, outdir = fun_dir, workdir = fun_dir)
build_episode_md <- function(path, hash = NULL, outdir = path_built(path), 
                             workdir = path_built(path), 
                             workenv = new.env(), profile = "lesson-requirements", quiet = FALSE) {

  # define the output
  md <- fs::path_ext_set(fs::path_file(path), "md")
  outpath <- fs::path(outdir, md)

  # Set up the arguments 
  root <- root_path(path)
  prof <- fs::path(root, "renv", "profiles", profile)
  # If we have consent to use renv and the profile exists, then we can use renv,
  # otherwise, we need to use the system library
  has_consent <- getOption("sandpaper.use_renv") && fs::dir_exists(prof)
  args <- list(
    path    = path,
    hash    = hash,
    workenv = workenv,
    outpath = outpath,
    workdir = workdir,
    root    = if (has_consent) root else "",
    quiet   = quiet
  )

  # Build the article in a separate  process via {callr}
  # ==========================================================
  #
  # Note that this process can NOT use any internal functions
  sho <- !(quiet || identical(Sys.getenv("TESTTHAT"), "true"))
  callr::r(
    func = callr_build_episode_md,
    args = args,
    show = !quiet,
    spinner = sho,
    env = c(callr::rcmd_safe_env(),
      "RENV_PROFILE" = profile,
      "RENV_CONFIG_CACHE_SYMLINKS" = renv_cache_available())
  )

  invisible(outpath)
}
