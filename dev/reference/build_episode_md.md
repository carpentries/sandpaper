# Build an episode to markdown

This uses [`knitr::knit()`](https://rdrr.io/pkg/knitr/man/knit.html)
with custom options set for the Carpentries template. It runs in a
separate process to avoid issues with user-specific options bleeding in.

## Usage

``` r
build_episode_md(
  path,
  hash = NULL,
  outdir = path_built(path),
  workdir = path_built(path),
  workenv = globalenv(),
  profile = "lesson-requirements",
  quiet = FALSE,
  error = TRUE
)
```

## Arguments

- path:

  path to the RMarkdown file

- hash:

  hash to prepend to the output. This parameter is deprecated and is
  effectively useless.

- outdir:

  the directory to write to

- workdir:

  the directory where the episode should be rendered

- workenv:

  an environment to use for evaluation. Defaults to the global
  environment, which evaluates to the environment from
  [`callr::r()`](https://callr.r-lib.org/reference/r.html).

- quiet:

  if `TRUE`, output is suppressed, default is `FALSE` to show `{knitr}`
  output.

- error:

  if `TRUE` (default) errors do not make an invalid build. This can be
  set to false to cause the build to fail if an error occurs. This is
  generally controlled via the `fail_on_error` config option.

## Value

the path to the output, invisibly

## Note

this function is for internal use, but exported for those who know what
they are doing.

## See also

[`render_html()`](https://carpentries.github.io/sandpaper/dev/reference/render_html.md),
[`build_episode_html()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_html.md)

## Examples

``` r
if (.Platform$OS.type == "windows") {
  options("sandpaper.use_renv" = FALSE)
}
if (!interactive() && getOption("sandpaper.use_renv")) {
  old <- renv::config$cache.symlinks()
  options(renv.config.cache.symlinks = FALSE)
  on.exit(options(renv.config.cache.symlinks = old), add = TRUE)
}
fun_dir <- tempfile()
dir.create(fs::path(fun_dir, "episodes"), recursive = TRUE)
fun_file <- file.path(fun_dir, "episodes", "fun.Rmd")
file.create(fun_file)
#> [1] TRUE
txt <- c(
 "---\ntitle: Fun times\n---\n\n",
 "# new page\n",
 "This is coming from `r R.version.string`"
)
writeLines(txt, fun_file)
res <- build_episode_md(fun_file, outdir = fun_dir, workdir = fun_dir)
#> 
#> 
#> processing file: /tmp/RtmpofsREx/file1c8b76954319/episodes/fun.Rmd
#> 1/1
#> output file: /tmp/RtmpofsREx/file1c8b76954319/fun.md
#> 
#> 
```
