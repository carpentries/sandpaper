# Provision an aggregate page in a lesson

A function that will provision page using a reusable template
provisioned for aggregate pages used in this lesson to avoid the
unnecessary re-rendering of already rendered content.

## Usage

``` r
provision_agg_page(pkg, title = "Key Points", slug = "key-points", new = FALSE)

provision_extra_template(pkg, quiet = TRUE)
```

## Arguments

- pkg:

  an object created via
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
  of a lesson.

- title:

  the new page title

- slug:

  the slug for the page (e.g. "aio" will become "aio.html")

- new:

  if `TRUE`, (default), the page will be generated from a new template.
  If `FALSE`, the page is assumed to have been pre-built and should be
  appended to.

## Value

- `provision_agg_page()`: a list:

  - `$learner`: an `xml_document` templated for the learner page

  - `$instructor`: an `xml_document` templated for the instructor page

  - `$needs_episodes`: a logical indicating if the page should be
    completly rebuilt (currently default to TRUE)

- `provision_extra_template()`: invisibly, a copy of a global list of
  HTML template content available in the internal global object
  `sandpaper:::.html`:

  - `.html$template$extra$learner`: the rendered learner template as a
    string

  - `.html$template$extra$instructor`: the rendered instructor template
    as a string

## Details

Pkgdown provides a lot of services in its rendering:

- cross-linking

- syntax highlighting

- dynamic templating

- etc.

The problem is that all of this effort takes time and it scales with the
size of the page being rendered such that in some cases it can take ~2
seconds for the All in One page of a small lesson. Creating aggregate
pages after all of the markdown content has been rendered should not
involve re-rendering content.

Luckily, reading in content with
[`xml2::read_html()`](http://xml2.r-lib.org/reference/read_xml.md) is
very quick and using XPath queries, we can take the parts we need from
the rendered content and insert it into a template, which we store as a
character in the `.html` global object so it can be passed around to
other functions without needing an argument.

`provision_agg_page()` makes a copy of this cache, replaces the FIXME
values with the appropriate elements, and returns an object created from
[`xml2::read_html()`](http://xml2.r-lib.org/reference/read_xml.md) for
each of the instructor and learner veiws.

## Examples

``` r
if (FALSE) { # only run if you have provisioned a pkgdown site
  lsn_site <- "/path/to/lesson/site"
  pkg <- pkgdown::as_pkgdown(lsn_site)

  # create an AIO page
  provision_agg_page(pkg, title = "All In One", slug = "aio", quiet = FALSE)
}
```
