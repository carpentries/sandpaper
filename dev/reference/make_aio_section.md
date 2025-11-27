# Make a section and place it inside the All In One page

When an episode needs to be added to the AiO, this will insert the XML
nodes from the episode contents in its own section inside the All In One
page.

## Usage

``` r
make_aio_section(name, contents, parent)
```

## Arguments

- name:

  the name of the section, prefixed with `episode-`

- contents:

  the episode contents from
  [`get_content()`](https://carpentries.github.io/sandpaper/dev/reference/get_content.md)

- parent:

  the parent div of the AiO page.

## Value

the section that was added to the parent

## See also

[`build_aio()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md),
[`get_content()`](https://carpentries.github.io/sandpaper/dev/reference/get_content.md)

## Examples

``` r
if (FALSE) {
  lsn <- "/path/to/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  # read in the All in One page and extract its content
  aio <- get_content("aio", content = "self::*", pkg = pkg)
  episode_content <- get_content("01-introduction", pkg = pkg)
  make_aio_section("aio-01-introduction",
    contents = episode_content, parent = aio
  )
}
```
