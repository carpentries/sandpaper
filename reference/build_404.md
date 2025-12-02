# Build the 404 page for a lesson

Build the 404 page for a lesson

## Usage

``` r
build_404(pkg, quiet = FALSE)
```

## Arguments

- pkg:

  a list object generated from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)

- quiet:

  passed to
  [`build_html()`](https://carpentries.github.io/sandpaper/reference/build_html.md).
  When `FALSE` (default), a message will be printed to the screen about
  the build progress. When `TRUE`, no messages are generated.

## Value

`TRUE` if the page was successfully generated

## Details

During the lesson build process, a 404 page with absolute links back to
the source pages must be generated otherwise, subsequent attempts to
escape the 404 page will be futile.

This function is intended to be run on a lesson website that has already
been built and is called for its side-effect of creating a 404 page.

## See also

[`build_site()`](https://carpentries.github.io/sandpaper/reference/build_site.md)
which calls this function and
[`build_html()`](https://carpentries.github.io/sandpaper/reference/build_html.md),
which this function calls.
