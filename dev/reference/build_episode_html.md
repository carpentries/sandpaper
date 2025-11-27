# Build a single episode html file

This is a Carpentries-specific wrapper around
[`pkgdown::render_page()`](https://pkgdown.r-lib.org/reference/render_page.html)
with templates from `{varnish}`. This function is largely for internal
use and will likely change.

## Usage

``` r
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
```

## Arguments

- path_md:

  the path to the episode markdown (not RMarkdown) file (usually via
  [`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md)).

- path_src:

  the default is `NULL` indicating that the source file should be
  determined from the `sandpaper-source` entry in the yaml header. If
  this is not present, then this option allows you to specify that file.

- page_back:

  the URL for the previous page

- page_forward:

  the URL for the next page

- pkg:

  a `pkgdown` object containing metadata for the site

- quiet:

  if `TRUE`, messages are not produced. Defaults to `TRUE`.

- page_progress:

  an integer between 0 and 100 indicating the rounded percent of the
  page progress. Defaults to NULL.

- sidebar:

  a character vector of links to other episodes to use for the sidebar.
  The current episode will be replaced with an index of all the chapters
  in the episode.

- date:

  the date the episode was last built.

- glosario:

  a dictionary of terms read in from Glosario glossary.yaml on Github.
  Defaults to NULL.

## Value

`TRUE` if the page was successful, `FALSE` otherwise.

## Note

this function is for internal use, but exported for those who know what
they are doing.

## See also

[`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md),
[`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md),
[`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md),
[`render_html()`](https://carpentries.github.io/sandpaper/dev/reference/render_html.md)

## Examples

``` r
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
```
