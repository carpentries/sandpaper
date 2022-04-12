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
  this_lesson(home)
  page_globals <- setup_page_globals()
  slug <- get_slug(path_md)
  # search the cache to see if we have a pre-built HTML page
  body <- .html$get()[[slug]]
  if (length(body) == 0 || body == "") {
    body <- render_html(path_md, quiet = quiet)
    .html$set(slug, body)
  }
  if (body == "") {
    # if there is nothing in the page then we build nothing.
    return(NULL)
  }
  nodes <- xml2::read_html(body)
  fix_nodes(nodes)

  # setup varnish data
  this_page <- as_html(path_md)
  nav_list <- get_nav_data(path_md, path_src, home, 
    this_page, page_back, page_forward)

  page_globals$metadata$update(c(nav_list, list(date = list(modified = date))))
  page_globals$learner$update(c(nav_list, list(
    body      = use_learner(nodes),
    progress  = page_progress,
    updated   = date
  )))
  nav_list$page_back <- as_html(nav_list$page_back, instructor = TRUE)
  nav_list$page_forward <- as_html(nav_list$page_forward, instructor = TRUE)
  page_globals$instructor$update(c(nav_list, list(
    body      = use_instructor(nodes),
    progress  = page_progress,
    updated   = date
  )))

  build_html(template = "chapter", pkg = pkg, nodes = nodes,
    global_data = page_globals, path_md = path_md, quiet = quiet)

}

update_sidebar <- function(sidebar = NULL, nodes = NULL, path_md = NULL, title = NULL, instructor = TRUE) {
  if (is.null(sidebar)) return(sidebar)
  if (inherits(sidebar, "list-store")) {
    # if it's a list store, then we need to get the sidebar and update itself
    title <- if (is.null(title)) sidebar$get()[["pagetitle"]] else title
    sb <- update_sidebar(sidebar$get()[["sidebar"]], nodes, path_md, title,
      instructor)
    sidebar$set("sidebar", paste(sb, collapse = "\n"))
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
    page_back <- as_html(page_back)
  }
  if (!is.null(page_forward)) {
    pf_title <- if (page_forward == "index.md") NULL else get_trimmed_title(page_forward)
    page_forward <- as_html(page_forward)
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
