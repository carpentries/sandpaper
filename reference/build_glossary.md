# Build a page for aggregating glosario links found in lesson elements

Build a page for aggregating glosario links found in lesson elements

## Usage

``` r
build_glossary(pkg, pages = NULL, quiet = FALSE)

build_glossary_page(
  pkg,
  pages,
  title = "Glosario Links",
  slug = "reference",
  aggregate = "*",
  append = "self::node()",
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

- title:

  the new page title

- slug:

  the slug for the page (e.g. "aio" will become "aio.html")

- aggregate:

  a selector for the lesson content you want to aggregate. The default
  is "\*", which will aggregate links from all content. To grab only
  links from sections, use "section".

- append:

  a selector for the section of the page where the aggregate data should
  be placed. This defaults to "self::node()", which indicates that the
  entire page should be appended.

## Value

NULL, invisibly. This is called for its side-effect

## Details

We programmatically search through lesson content to find links that
point to glosario terms. We then aggregate these links into the
Reference.

## Note

This function assumes that you have already built all the episodes of
your lesson.

## Examples

``` r
if (FALSE) {
  # build_glossary_page() assumes that your lesson has been built and takes in a
  # pkgdown object, which can be created from the `site/` folder in your
  # lesson.
  lsn <- "/path/to/my/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  htmls <- read_all_html(pkg$dst_path)
  build_glossary_page(pkg, htmls, quiet = FALSE)
}
```
