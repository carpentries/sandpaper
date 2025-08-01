% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_episode.R
\name{build_episode_html}
\alias{build_episode_html}
\title{Build a single episode html file}
\usage{
build_episode_html(
  path_md,
  path_src = NULL,
  page_back = "index.md",
  page_forward = "index.md",
  pkg,
  quiet = FALSE,
  page_progress = NULL,
  sidebar = NULL,
  date = NULL,
  glosario = NULL
)
}
\arguments{
\item{path_md}{the path to the episode markdown (not RMarkdown) file
(usually via \code{\link[=build_episode_md]{build_episode_md()}}).}

\item{path_src}{the default is \code{NULL} indicating that the source file should
be determined from the \code{sandpaper-source} entry in the yaml header. If this
is not present, then this option allows you to specify that file.}

\item{page_back}{the URL for the previous page}

\item{page_forward}{the URL for the next page}

\item{pkg}{a \code{pkgdown} object containing metadata for the site}

\item{quiet}{if \code{TRUE}, messages are not produced. Defaults to \code{TRUE}.}

\item{page_progress}{an integer between 0 and 100 indicating the rounded
percent of the page progress. Defaults to NULL.}

\item{sidebar}{a character vector of links to other episodes to use for the
sidebar. The current episode will be replaced with an index of all the
chapters in the episode.}

\item{date}{the date the episode was last built.}

\item{glosario}{a dictionary of terms read in from Glosario glossary.yaml
on Github. Defaults to NULL.}
}
\value{
\code{TRUE} if the page was successful, \code{FALSE} otherwise.
}
\description{
This is a Carpentries-specific wrapper around \code{\link[pkgdown:render_page]{pkgdown::render_page()}} with
templates from \code{{varnish}}. This function is largely for internal use and will
likely change.
}
\note{
this function is for internal use, but exported for those who know what
they are doing.
}
\examples{
if (FALSE) {
# 2022-04-15: this suddenly started throwing a check error
# that says "connections left open: (file) and I can't figure out where the
# hell its coming from, so I'm just going to not run this :(
if (.Platform$OS.type == "windows") {
  options("sandpaper.use_renv" = FALSE)
}
if (!interactive() && getOption("sandpaper.use_renv")) {
  old <- renv::config$cache.symlinks()
  options(renv.config.cache.symlinks = FALSE)
  on.exit(options(renv.config.cache.symlinks = old), add = TRUE)
}
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = TRUE)
suppressMessages(set_episodes(tmp, get_episodes(tmp), write = TRUE))
if (rmarkdown::pandoc_available("2.11")) {
  # we can only build this if we have pandoc
  build_lesson(tmp)
}

# create a new file in files
fun_file <- file.path(tmp, "episodes", "files", "fun.Rmd")
txt <- c(
 "---\ntitle: Fun times\n---\n\n",
 "# new page\n",
 "This is coming from `r R.version.string`\n",
 "::: testimonial\n\n#### testimony!\n\nwhat\n:::\n"
)
file.create(fun_file)
on.exit(unlink(tmp, recursive = TRUE, force = TRUE))
writeLines(txt, fun_file)
hash <- tools::md5sum(fun_file)
res <- build_episode_md(fun_file, hash)
if (rmarkdown::pandoc_available("2.11")) {
  # we need to set the global values
  sandpaper:::set_globals(res)
  on.exit(clear_globals(), add = TRUE)
  # we can only build this if we have pandoc
  build_episode_html(res, path_src = fun_file,
    pkg = pkgdown::as_pkgdown(file.path(tmp, "site"))
  )
}
}
}
\seealso{
\code{\link[=build_episode_md]{build_episode_md()}}, \code{\link[=build_lesson]{build_lesson()}}, \code{\link[=build_markdown]{build_markdown()}}, \code{\link[=render_html]{render_html()}}
}
\keyword{internal}
