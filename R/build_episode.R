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
#'   # we need to set the global values
#'   sandpaper:::set_globals(res)
#'   on.exit(clear_globals(), add = TRUE)
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
  if (body == "") {
    # if there is nothing in the page then we build nothing.
    return(NULL)
  }
  nodes <- xml2::read_html(body)
  fix_nodes(nodes)

  # setup varnish data
  page_globals <- setup_page_globals()
  page_globals$instructor <- instructor_globals$copy()
  sidebar <- page_globals$instructor$get()[["sidebar"]]
  this_page <- as_html(path_md, instructor = TRUE)
  nav_list <- get_nav_data(path_md, path_src, home, 
    this_page, page_back, page_forward)
  sidebar <- update_sidebar(sidebar, nodes, path_md, nav_list$pagetitle, 
    instructor = TRUE)

  # update metadata
  this_metadata$update(list(
    date = list(modified = date),
    pagetitle = nav_list$pagetitle,
    url = paste0(this_metadata$get()$url, this_page)
  ))

  instructor_list <- list(
    body          = use_instructor(nodes),
    sidebar       = paste(sidebar, collapse = "\n"),
    progress      = page_progress,
    updated       = date,
    json          = create_metadata_jsonld(home),
    instructor    = TRUE
  )

  page_globals$instructor$update(c(nav_list, instructor_list))

  # ------------------------------------------- Run pkgdown::render_page()
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
  ipath <- fs::path(pkg$dst_path, "instructor")
  if (!fs::dir_exists(ipath)) fs::dir_create(ipath)

  modified <- pkgdown::render_page(pkg, 
    "chapter",
    data = page_globals$instructor$get(),
    depth = 1L,
    path = this_page,
    quiet = quiet
  )
  if (modified) {
    sidebar <- update_sidebar(sidebar, nodes, path_md, nav_list$pagetitle, 
      instructor = FALSE)

    this_metadata$set("url", 
      paste0(this_metadata$get()$url, "/", as_html(this_page))
    )

    learner_list <- modifyList(instructor_list,
      list(
        body = use_learner(nodes),
        sidebar = paste(sidebar, collapse = "\n"),
        instructor = FALSE,
        page_back = fs::path_file(page_back), 
        page_forward = fs::path_file(page_forward), 
        json         = create_metadata_jsonld(home),
        sidebar      = paste(gsub("instructor/", "", sidebar), collapse = "\n")
      )
    )

    dat_learner <- learner_globals$copy()
    dat_learner$update(learner_list)
    pkgdown::render_page(pkg, 
      "chapter",
      data = dat_learner$get(),
      depth = 0L,
      path = as_html(this_page),
      quiet = quiet
    )
  }
}

update_sidebar <- function(sidebar = NULL, nodes = NULL, path_md = NULL, title = NULL, instructor = TRUE) {
  if (is.null(sidebar)) return(sidebar)
  if (inherits(sidebar, "list-store")) {
    return(update_sidebar(sidebar$get()[["sidebar"]], nodes, path_md, 
      title = if (is.null(title)) sidebar$get()[["pagetitle"]] else title, 
      instructor))
  }
  this_page <- as_html(path_md)
  to_change <- grep(paste0("[<]a href=['\"]", this_page, "['\"]"), sidebar)
  if (length(to_change)) {
    sidebar[to_change] <- create_sidebar_item(nodes, title, "current")
  }
  sidebar
}

#' Generate the navigation data for a page
#'
#' @inheritParams build_episode_html
#' @param home the path to the lesson home
#' @param this_page the current page relative html address
#' @keywords internal
get_nav_data <- function(path_md, path_src = NULL, home = NULL, 
  this_page = NULL, page_back = NULL, page_forward = NULL) {
  if (is.null(home)) {
    home <- root_path(path_md)
  }
  if (is.null(this_page)) {
    this_page <- as_html(path_md)
  }
  yaml <- yaml::yaml.load(politely_get_yaml(path_md), eval.expr = FALSE)
  path_src <- if (is.null(path_src)) path_md else path_src

  title <- parse_title(yaml$title)
  pb_title <- NULL
  pf_title <- NULL

  if (!is.null(page_back)) {
    pb_title <- if (page_back == "index.md") "Home" else get_trimmed_title(page_back)
    page_back <- as_html(page_back, instructor = TRUE)
  }
  if (!is.null(page_forward)) {
    pf_title <- if (page_forward == "index.md") NULL else get_trimmed_title(page_forward)
    page_forward <- as_html(page_forward, instructor = TRUE)
  }
  list(
    pagetitle     = title,
    minutes       = as.integer(yaml$teaching) + as.integer(yaml$exercises),
    file_source   = fs::path_rel(path_src, start = home),
    this_page     = fs::path_file(this_page),
    page_back     = page_back,
    back_title    = pb_title,
    page_forward  = page_forward,
    forward_title = pf_title
  )
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
