# Update github workflows

This function copies and updates the workflows to run `{sandpaper}`.

## Usage

``` r
update_github_workflows(
  path = ".",
  files = "",
  overwrite = TRUE,
  clean = "*.yaml",
  quiet = FALSE
)
```

## Arguments

- path:

  path to the current lesson.

- files:

  the files to include in the update. Defaults to an empty string, which
  will update all files

- overwrite:

  if `TRUE` (default), the file(s) will be overwritten.

- clean:

  glob of files to be cleaned before writing. Defaults to `"*.yaml"`. to
  remove all files with the four-letter "yaml" extension (but it will
  not remove the ".yml" extension). You can also specify a whole file
  name like "workflow.yaml" to remove one specific file. If you do not
  want to clean, set this to `NULL`.

- quiet:

  if `TRUE`, the process will not output any messages, default is
  `FALSE`, which will report on the progress of each step.

## Value

the paths to the new files.
