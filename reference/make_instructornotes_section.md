# Make a section of aggregated instructor notes

This will append instructor notes from the inline sections of the lesson
to the instructor-notes page, separated by section and `<hr>` elements.

## Usage

``` r
make_instructornotes_section(name, contents, parent)
```

## Arguments

- name:

  the name of the section, (may or may not be prefixed with `images-`)

- contents:

  an `xml_nodeset` of figure elements from
  [`get_content()`](https://carpentries.github.io/sandpaper/reference/get_content.md)

- parent:

  the parent div of the images page

## Value

the section that was added to the parent

## Note

On the learner view, instructor notes will not be present

## See also

[`build_instructor_notes()`](https://carpentries.github.io/sandpaper/reference/build_agg.md),
[`get_content()`](https://carpentries.github.io/sandpaper/reference/get_content.md)

## Examples

``` r
if (FALSE) {
  lsn <- "/path/to/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  # read in the All in One page and extract its content
  notes <- get_content("instructor-notes",
    content =
      "section[@id='aggregate-instructor-notes']", pkg = pkg, instructor = TRUE
  )
  agg <- "/div[contains(@class, 'instructor-note')]//div[@class='accordion-body']"
  note_content <- get_content("01-introduction", content = agg, pkg = pkg)
  make_instructornotes_section("01-introduction",
    contents = note_content,
    parent = notes
  )

  # NOTE: if the object for "contents" ends with "_learn", no content will be
  # appended
  note_learn <- note_content
  make_instructornotes_section("01-introduction",
    contents = note_learn,
    parent = notes
  )
}
```
