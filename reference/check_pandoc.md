# Check the existence of pandoc

This function adds context to
[`rmarkdown::pandoc_available()`](https://pkgs.rstudio.com/rmarkdown/reference/pandoc_available.html)
and provides an error message directing the user to download the latest
version of pandoc or RStudio Desktop.

## Usage

``` r
check_pandoc(quiet = TRUE, pv = "2.11", rv = "1.4")
```

## Arguments

- quiet:

  if `TRUE`, no message will be emitted, otherwise the pandoc version
  and path will be sent as a message (stderr) to the screen.

- pv:

  the minimum pandoc version

- rv:

  the minimum rstudio version (if available)

## Examples

``` r
# NOTE: this is an internal function, so there is no guarantee that the usage
# will remain the same across time. This is merely for demonstration purposes
# only.

# Check for pandoc ----------------------
asNamespace("sandpaper")$check_pandoc(quiet = FALSE)
#> ◉ pandoc found
#>   version : 3.1.11
#>   path    : /opt/hostedtoolcache/pandoc/3.1.11/x64

# Message emitted when pandoc cannot be found --------
try(asNamespace("sandpaper")$check_pandoc(quiet = FALSE, pv = "999"))
#>  sandpaper requires pandoc version 999 or higher.
#> ! You have pandoc version 3.1.11 in /opt/hostedtoolcache/pandoc/3.1.11/x64
#> → Please visit <https://pandoc.org/installing.html> to install the latest version.
#> Error : Incorrect pandoc version
```
