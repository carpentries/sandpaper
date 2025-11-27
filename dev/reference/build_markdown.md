# Build plain markdown from the RMarkdown episodes

In the spirit of `{hugodown}`, This function will build plain markdown
files as a minimal R package in the `site/` folder of your `{sandpaper}`
lesson repository tagged with the hash of your file to ensure that only
files that have changed are rebuilt.

## Usage

``` r
build_markdown(
  path = ".",
  rebuild = FALSE,
  quiet = FALSE,
  slug = NULL,
  skip_manage_deps = FALSE
)
```

## Arguments

- path:

  the path to your repository (defaults to your current working
  directory)

- rebuild:

  if `TRUE`, everything will be built from scratch as if there was no
  cache. Defaults to `FALSE`, which will only build markdown files that
  haven't been built before.

## Value

`TRUE` if it was successful, a character vector of issues if it was
unsuccessful.

## See also

[`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md)
