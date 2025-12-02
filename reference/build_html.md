# Build instructor and learner HTML page

Build instructor and learner HTML page

## Usage

``` r
build_html(
  template = "chapter",
  pkg,
  nodes,
  global_data,
  path_md,
  quiet = TRUE
)
```

## Arguments

- template:

  the name of the `{varnish}` template to use. Defaults to "chapter"

- pkg:

  an object created from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)

- nodes:

  an `xml_document` object. `nodes` will be a list of two
  `xml_documents`; one for instructors and one for learners so that the
  instructors have the schedule available to them. If both the
  instructor and learner page, it will be a single `xml_document`
  object.

- global_data:

  a list store object that contains copies of the global variables for
  the page, including metadata, navigation, and variables for the
  `{varnish}` templates.

- path_md:

  the path (absolute, relative, or filename) the current markdown file
  being processed.

- quiet:

  This parameter is passed to
  [`pkgdown::render_page()`](https://pkgdown.r-lib.org/reference/render_page.html)
  and will print the progress if `TRUE` (default).

## Value

`TRUE` if the page was built and `NULL` if it did not need to be rebuilt

## Details

This function is a central workhorse that connects the global lesson
metadata and the global variables for each page to the rendering engine:
`{pkgdown}`. It will perform the global operations that includes setting
up the navigation (via
[`update_sidebar()`](https://carpentries.github.io/sandpaper/reference/create_sidebar.md)),
adding metadata, and building both the instructor and learner versions
of the page (via
[`pkgdown::render_page()`](https://pkgdown.r-lib.org/reference/render_page.html)).

In the Workbench, there are three types of pages:

1.  primary content pages: these are primary content with a 1:1
    relationship between the source and the output. These are episodes
    along with custom learner and instructor content

2.  aggregate content pages: pages that are aggregated from other pages
    such as key points, all-in-one, images

3.  concatenated content pages: concatenations of source files and
    potentially aggregate data. Examples are index, learner profiles,
    and the instructor notes pages.

Each of these types of pages have their own process for setting up
content, which gets processed before its passed here.

## See also

[`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md)
for definitions of the global data,
[`update_sidebar()`](https://carpentries.github.io/sandpaper/reference/create_sidebar.md)
for context of how the sidebar is updated,
