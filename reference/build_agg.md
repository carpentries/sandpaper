# Build a page for aggregating common elements

Build a page for aggregating common elements

## Usage

``` r
build_aio(pkg, pages = NULL, quiet = FALSE)

build_images(pkg, pages = NULL, quiet = FALSE)

build_instructor_notes(pkg, pages = NULL, built = NULL, quiet)

build_keypoints(pkg, pages = NULL, quiet = FALSE)

build_agg_page(
  pkg,
  pages,
  title = NULL,
  slug = NULL,
  aggregate = "section",
  append = "self::node()",
  prefix = FALSE,
  quiet = FALSE
)
```

## Arguments

- pkg:

  an object created via
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
  of a lesson.

- pages:

  output from the function
  [`read_all_html()`](https://carpentries.github.io/sandpaper/reference/read_all_html.md):
  a nested list of `xml_document` objects representing episodes in the
  lesson

- quiet:

  if `TRUE`, no messages will be emitted. If FALSE, pkgdown will report
  creation of the temporary file.

- built:

  a vector of markdown documents that have recently been rebuilt (for
  future use)

- title:

  the new page title

- slug:

  the slug for the page (e.g. "aio" will become "aio.html")

- aggregate:

  a selector for the lesson content you want to aggregate. The default
  is "section", which will aggregate all sections, but nothing outside
  of the sections. To grab everything in the page, use "\*"

- append:

  a selector for the section of the page where the aggregate data should
  be placed. This defaults to "self::node()", which indicates that the
  entire page should be appended.

- prefix:

  flag to add a prefix for the aggregated sections. Defaults to `FALSE`.

## Value

NULL, invisibly. This is called for its side-effect

## Details

Building an aggregate page is very much akin to copy/paste—you take the
same elements across several pages and paste them into one large page.
We can do this programmatically by using XPath to extract nodes from
pages and add them into the document.

To customise the page, we need a few things:

1.  a title

2.  a slug

3.  a method to prepare and insert the extracted content (e.g.
    [`make_aio_section()`](https://carpentries.github.io/sandpaper/reference/make_aio_section.md))

## Note

This function assumes that you have already built all the episodes of
your lesson.

## Examples

``` r
if (FALSE) {
  # build_aio() assumes that your lesson has been built and takes in a
  # pkgdown object, which can be created from the `site/` folder in your
  # lesson.
  lsn <- "/path/to/my/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  htmls <- read_all_html(pkg$dst_path)
  build_aio(pkg, htmls, quiet = FALSE)
  build_keypoints(pkg, htmls, quiet = FALSE)
}
```
