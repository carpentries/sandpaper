# Template files

Use these files as templates for your own sandpaper lesson

## Usage

``` r
template_gitignore()

template_episode()

template_links()

template_cff()

template_citation()

template_config()

template_conduct()

template_index()

template_license()

template_contributing()

template_setup()

template_pkgdown()

template_placeholder()

template_pr_diff()

template_sidebar_item()

template_metadata()
```

## Value

a character string with the path to the template within the
`{sandpaper}` repo.

## Examples

``` r
cat(readLines(template_gitignore(), n = 6), sep = "\n")
#> # sandpaper files
#> episodes/*html
#> site/*
#> !site/README.md
#> 
#> # History files
```
