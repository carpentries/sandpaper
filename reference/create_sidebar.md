# Create the sidebar for varnish

Varnish uses a sidebar for navigation across and within an episode. Each
episode's sidebar is different because there needs to be a clear
indicator which episode is the current one within the sidebar.

## Usage

``` r
create_resources_dropdown(files, type = "learners")

create_sidebar(
  chapters,
  name = "",
  html = "<a href='https://carpentries.org'/>",
  disable_numbering = FALSE
)

update_sidebar(
  sidebar = NULL,
  nodes = NULL,
  this_page = NULL,
  title = NULL,
  item = NULL
)
```

## Arguments

- files:

  a vector of markdown file names

- type:

  one of "learners" (default) or "instructors". If it is learners, the
  setup page will be excluded since it is included in the index. For
  "instructors", the instructor notes are included and the learner
  profiles are included.

- chapters:

  a character vector of paths to markdown chapters

- name:

  the name of the current chapter

- html:

  the html of the current chapter. defaults to a link that will produce
  a sidebar with no links to headings.

- disable_numbering:

  a boolean indicating if the sidebar should not automatically number
  the chapters. Defaults to `FALSE`. If `TRUE`, developers should
  consider adding their own custom numbering to the chapter titles in
  the frontmatter.

- sidebar:

  an object of class "list-store" which has a `"sidebar"` element in the
  stored list. See
  [`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md).

- nodes:

  the HTML nodes of an HTML page

- this_page:

  the path to the current HTML page

- title:

  the current title

- item:

  the index of the sidebar item to update

## Value

a character vector of HTML divs that can be appended to display the
sidebar.

## Details

This function creates that sidebar.

## See also

[`create_sidebar_item()`](https://carpentries.github.io/sandpaper/reference/create_sidebar_item.md)
for creation of individual sidebar items,
[`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md)
for where `create_sidebar()` is called and
[`build_html()`](https://carpentries.github.io/sandpaper/reference/build_html.md)
for where `update_sidebar()` is called.
