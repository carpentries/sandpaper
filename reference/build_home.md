# Build a home page for a lesson

Build a home page for a lesson

## Usage

``` r
build_home(pkg, quiet, next_page = NULL)
```

## Arguments

- pkg:

  a list generated from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
  from the `site/` folder of a lesson.

- quiet:

  a boolean passed to
  [`build_html()`](https://carpentries.github.io/sandpaper/reference/build_html.md).
  if `TRUE`, this will have pkgdown report what files are being built

- next_page:

  the next page file name. This will allow the navigation element to be
  set up correctly on the navigation bar

## Value

nothing. This is used for its side-effect

## Details

The index page of the lesson is a combination of two pages:

1.  index.md (or README if the index does not exist)

2.  learners/setup.md

This function uses
[`render_html()`](https://carpentries.github.io/sandpaper/reference/render_html.md)
to convert the page into HTML, which gets passed on to the "syllabus" or
"overview" templates in `{varnish}` (via the
[`build_html()`](https://carpentries.github.io/sandpaper/reference/build_html.md)
function as the `{{{ readme }}}` and `{{{ setup }}}` keys.
