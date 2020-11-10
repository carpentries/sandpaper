#' Build a single episode html file
#'
#' @param path_md the path to the episode markdown (not RMarkdown) file
#'   (usually via [build_episode_md()]).
#' @param path_src the path to the source file (defaults `path_md`)
#' @param page_back the URL for the previous page
#' @param page_forward the URL for the next page
#' @param pkg a `pkgdown` object containing metadata for the site
#' @param quiet if `TRUE`, messages are not produced. Defaults to `TRUE`.
#' 
#' @return `TRUE` if the page was successful, `FALSE` otherwise.
#' @export
#' @note this function is for internal use, but exported for those who know what
#'   they are doing. 
#' @keywords internal
#' @seealso [build_episode_md()], [build_lesson()], [build_markdown()]
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE)
#' suppressWarnings(set_schedule(tmp, get_schedule(tmp), write = TRUE))
#' build_lesson(tmp)
#' 
#' # create a new file in extras
#' fun_file <- file.path(tmp, "episodes", "extras", "fun.Rmd")
#' txt <- c(
#'  "---\ntitle: Fun times\n---\n\n",
#'  "# new page\n", 
#'  "This is coming from `r R.version.string`"
#' )
#' file.create(fun_file)
#' writeLines(txt, fun_file)
#' hash <- tools::md5sum(fun_file)
#' res <- build_episode_md(fun_file, hash)
#' build_episode_html(res, 
#'   pkg = pkgdown::as_pkgdown(file.path(tmp, "site"))
#' )
build_episode_html <- function(path_md, path_src = path_md, 
                               page_back = "index.md", page_forward = "index.md", 
                               pkg, quiet = FALSE) {
  home <- root_path(path_md)
  body <- render_html(path_md, quiet = quiet)
  yaml <- yaml::yaml.load(politely_get_yaml(path_md))
  pkgdown::render_page(pkg, 
    "title-body",
    data = list(
      # NOTE: we can add anything we want from the YAML header in here to
      # pass on to the template.
      body         = body,
      pagetitle    = parse_title(yaml$title),
      teaching     = yaml$teaching,
      exercises    = yaml$exercises,
      file_source  = fs::path_rel(path_src, start = home),
      page_back    = as_html(page_back),
      left         = if (page_back == "index.md") "up" else "left",
      page_forward = as_html(page_forward),
      right        = if (page_forward == "index.md") "up" else "right"
    ), 
    path = as_html(path_md),
    quiet = quiet
  )
} 

#' Build an episode to markdown
#'
#' This uses [knitr::knit()] with custom options set for the Carpentries
#' template and prepends a hash to the yaml header
#'
#' @param path path to the RMarkdown file
#' @param hash hash to prepend to the output
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
#' @seealso [build_episode_html()]
#' @examples
#' fun_dir <- tempfile()
#' dir.create(fun_dir)
#' fun_file <- file.path(fun_dir, "fun.Rmd")
#' file.create(fun_file)
#' txt <- c(
#'  "---\ntitle: Fun times\n---\n\n",
#'  "# new page\n", 
#'  "This is coming from `r R.version.string`"
#' )
#' writeLines(txt, fun_file)
#' hash <- tools::md5sum(fun_file)
#' res <- build_episode_md(fun_file, hash, outdir = fun_dir, workdir = fun_dir)
build_episode_md <- function(path, hash, outdir = path_built(path), 
                             workdir = path_built(path), 
                             env = new.env(), quiet = FALSE) {

  # define the output
  md <- fs::path_ext_set(fs::path_file(path), "md")
  outpath <- fs::path(outdir, md)

  # Set up the arguments 
  args <- list(
    path    = path,
    hash    = hash,
    env     = env,
    outpath = outpath,
    workdir = workdir,
    quiet   = quiet
  )

  # Build the article in a separate process via {callr}
  # ==========================================================
  #
  # Note that this process can NOT use any internal functions
  callr::r(function(path, hash, env, outpath, workdir, quiet) {
    # Set knitr options for output ---------------------------
    oknit <- knitr::opts_chunk$get()
    on.exit(knitr::opts_chunk$restore(oknit), add = TRUE)

    slug <- fs::path_ext_remove(fs::path_file(outpath))

    knitr::opts_chunk$set(
      comment       = "",
      fig.align     = "center",
      class.output  = "output",
      class.error   = "error",
      class.warning = "warning",
      class.message = "output",
      fig.path      = fs::path("fig", paste0(slug, "-"))
    )

    # Set the working directory -----------------------------
    wd <- getwd()
    on.exit(setwd(wd), add = TRUE)
    setwd(workdir)

    # Generate markdown -------------------------------------
    res <- knitr::knit(
      text = readLines(path, encoding = "UTF-8"), 
      envir = env, 
      quiet = quiet,
      encoding = "UTF-8"
    )

    # append md5 hash to top of file ------------------------
    output <- sub(
      "^---",
      paste("---\nsandpaper-digest:", hash),
      res
    )

    # write file to disk ------------------------------------
    writeLines(output, outpath)
  }, args = args, show = !quiet)

  invisible(outpath)
}
