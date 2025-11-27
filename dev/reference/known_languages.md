# Show a list of languages known by `{sandpaper}`

Show a list of languages known by `{sandpaper}`

## Usage

``` r
known_languages()
```

## Value

a character vector of language codes known by `{sandpaper}`

## Details

The known languages are translations of menu and navigational elements
that exist in `{sandpaper}`. If these elements have not been translated
for a given language and you would like to add translations for them,
please consult
[`vignette("translations", package = "sandpaper")`](https://carpentries.github.io/sandpaper/dev/articles/translations.md)
for details of how to do so in the source code for `{sandpaper}`.

### List of Known Languages:

    #> - en
    #> - de
    #> - es
    #> - fr
    #> - it
    #> - ja
    #> - uk

## See also

[`vignette("translations", package = "sandpaper")`](https://carpentries.github.io/sandpaper/dev/articles/translations.md)
for an overview of providing translations.

## Examples

``` r
known_languages()
#> [1] "en" "de" "es" "fr" "it" "ja" "uk"
```
