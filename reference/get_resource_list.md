# Get the full resource list of markdown files

Get the full resource list of markdown files

## Usage

``` r
get_resource_list(path, trim = FALSE, subfolder = NULL, warn = FALSE)
```

## Arguments

- path:

  path to the lesson

- trim:

  if `TRUE`, trim the paths to be relative to the lesson directory.
  Defaults to `FALSE`, which will return the absolute paths

- subfolder:

  the subfolder to check. If this is `NULL`, all folders will checked
  and returned (default), otherwise, this should be a string specifying
  the folder name in the lesson (e.g. "episodes").

- warn:

  if `TRUE` and `subfolder = "episodes"`, a message is issued to the
  user if the episodes field of the configuration file is empty.

## Value

a list of files by subfolder in the order they should appear in the
menu.

## See also

[`build_status()`](https://carpentries.github.io/sandpaper/reference/build_status.md)
