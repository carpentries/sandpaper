# Get sections from an episode's HTML page

Get sections from an episode's HTML page

## Usage

``` r
get_content(
  episode,
  content = "*",
  label = FALSE,
  pkg = NULL,
  instructor = FALSE
)
```

## Arguments

- episode:

  an object of class `xml_document`, a path to a markdown or html file
  of an episode.

- content:

  an XPath fragment. defaults to "\*"

- label:

  if `TRUE`, elements will be named by their ids. This is best used when
  content = "section".

- pkg:

  an object created via
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
  of a lesson.

- instructor:

  if `TRUE`, the instructor version of the episode is read, defaults to
  `FALSE`. This has no effect if the episode is an `xml_document`.

## Details

The contents of the lesson are contained in the following templating
cascade:

    <body>
      <div class='container'>
        <div class='row'>
          <div class='[...] primary-content'>
            <main>
              <div class='[...] lesson-content'>
                CONTENT HERE

This function will extract the content from the episode without the
templating.

## Examples

``` r
if (FALSE) {
  lsn <- "/path/to/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  # for AiO pages, this will return only the top-level sections:
  get_content("aio", content = "section", label = TRUE, pkg = pkg)

  # for episode pages, this will return everything that's not template
  get_content("01-introduction", pkg = pkg)

  # for things that are within lessons but we don't know their exact location,
  # we can prefix a `/` to double up the slash, which will produce
}
```
