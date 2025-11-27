# Set the necessary common global variables for use in the `{varnish}` template.

This will enforce four global lists:

## Usage

``` r
set_globals(path)
```

## Arguments

- path:

  the path to the lesson

## Details

1.  `.resources`, which is equivalent to the output of
    [`get_resource_list()`](https://carpentries.github.io/sandpaper/dev/reference/get_resource_list.md)

2.  `this_metadata`, which contains the metadata common for the lesson

3.  `learner_globals` the navigation items for the learners

4.  `instructor_globals` the namvigation items for the instructors

The things that are added:

- `sidebar` This is generated from
  [`create_sidebar()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar.md)
  and is the same in the learner and instructor globals with the
  exception of the first element.

- `more` This is the "More" dropdown menu, which is created via
  [`create_resources_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar.md).

- `resources` The same as "More", but positioned on the mobile sidebar.

- `{sandpaper,varnish,pegboard}_version` package versions of each
  package.
