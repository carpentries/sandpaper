# Site generator for sandpaper

This is a custom site generator for compatibility with
[`rmarkdown::site_generator()`](https://pkgs.rstudio.com/rmarkdown/reference/render_site.html).
For RStudio users, **placing this in the `index.md` yaml header will
make the knit button work**:

## Usage

``` r
sandpaper_site(input = ".", ...)
```

## Details

    site: sandpaper::sandpaper_site

This will be automatically added to the `index.md` for all sandpaper
sites from version 0.0.0.9013, so maintainers should not need to worry
about this.

Thanks goes to Yihui Xie for coming up with the concept of modular site
generators and for JJ Alaire for allowing sub-directory structures for
RMarkdown sites.
