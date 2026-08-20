# Return a function that loads snippet files from the given directories. This will be used to create a `snippets()` function in the episode build environment.

Return a function that loads snippet files from the given directories.
This will be used to create a `snippets()` function in the episode build
environment.

## Usage

``` r
bootstrap_snippet_loader(custom_snippets, base_snippets = NULL)
```

## Arguments

- custom_snippets:

  the path to the custom snippets directory (or `NULL` if none)

- base_snippets:

  the path to the base snippets directory (or `NULL` if none)

## Value

a function that takes a child file path and renders it as a snippet, or
returns the path to the snippet file if `render = FALSE`.
