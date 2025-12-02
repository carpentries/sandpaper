# Generate the navigation data for a page

Generate the navigation data for a page

## Usage

``` r
get_nav_data(
  path_md,
  path_src = NULL,
  home = NULL,
  this_page = NULL,
  page_back = NULL,
  page_forward = NULL
)
```

## Arguments

- path_md:

  the path to the episode markdown (not RMarkdown) file (usually via
  [`build_episode_md()`](https://carpentries.github.io/sandpaper/reference/build_episode_md.md)).

- path_src:

  the default is `NULL` indicating that the source file should be
  determined from the `sandpaper-source` entry in the yaml header. If
  this is not present, then this option allows you to specify that file.

- home:

  the path to the lesson home

- this_page:

  the current page relative html address

- page_back:

  the URL for the previous page

- page_forward:

  the URL for the next page
