# Show files in draft form

By default, `{sandpaper}` will use the files in alphabetical order as
they are presented in the folders, however, it is **strongly** for
authors to specify the order of the files in their lessons, so that it's
easy to rearrange or add, split, or rearrange files.

## Usage

``` r
get_drafts(
  path,
  folder = NULL,
  message = getOption("sandpaper.show_draft", TRUE)
)
```

## Arguments

- path:

  path to the the sandpaper lesson

- folder:

  the specific folder for which to list the draft files. Defaults to
  `NULL`, which indicates all folders listed in `config.yaml`.

- message:

  if `TRUE` (default), an informative message about the files that are
  in draft status are printed to the screen.

## Value

a vector of paths to files in draft and a message (if specified)

## Details

This mechanism also allows authors to work on files in a draft form
without them being published. This function will list and show the files
in draft for automation and audit.
