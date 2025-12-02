# Make a section of aggregated images

This will insert xml figure nodes into the images page, printing the alt
text descriptions for users who are not using screen readers.

## Usage

``` r
make_images_section(name, contents, parent)
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

## See also

[`build_images()`](https://carpentries.github.io/sandpaper/reference/build_agg.md),
[`get_content()`](https://carpentries.github.io/sandpaper/reference/get_content.md)

## Examples

``` r
if (FALSE) {
  lsn <- "/path/to/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  # read in the All in One page and extract its content
  img <- get_content("images", content = "self::*", pkg = pkg)
  fig_content <- get_content("01-introduction", content = "/figure", pkg = pkg)
  make_images_section("01-introduction", contents = fig_content, parent = img)
}
```
