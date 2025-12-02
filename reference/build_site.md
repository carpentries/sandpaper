# Wrapper for site builder

Wrapper for site builder

## Usage

``` r
build_site(
  path = ".",
  quiet = !interactive(),
  preview = TRUE,
  override = list(),
  slug = NULL,
  built = NULL
)
```

## Arguments

- path:

  the path to your repository (defaults to your current working
  directory)

- quiet:

  when `TRUE`, output is supressed

- preview:

  if `TRUE`, the rendered website is opened in a new window

- override:

  options to override (e.g. building to alternative paths). This is used
  internally and will likely be changed.

- slug:

  The slug for the file to preview in RStudio. If this is `NULL`, the
  preview will default to the home page. If you have an episode whose
  slug is 01-introduction, then setting `slug = "01-introduction"` will
  allow RStudio to open the preview window to the right page.

- built:

  a character vector of newly built files or NULL.

## Note

this assumes that the markdown files have already been built and will
not work otherwise
