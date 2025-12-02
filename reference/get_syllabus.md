# Create a syllabus for the lesson

This function is generally for internal use, but may be useful for those
who whish to automate creation of their own home pages.

## Usage

``` r
get_syllabus(path = ".", questions = FALSE, use_built = TRUE)
```

## Arguments

- path:

  the path to a lesson

- questions:

  if `TRUE`, the questions in the episodes will be added to the table.
  Defaults to `FALSE`.

- use_built:

  if `TRUE` (default), the rendered episodes will be used to generate
  the syllabus

## Value

a data frame containing the syllabus for the lesson with the timing,
links, and questions associated
