# Create a valid, opinionated yaml list for insertion into a whisker template

Create a valid, opinionated yaml list for insertion into a whisker
template

## Usage

``` r
yaml_list(thing)
```

## Arguments

- thing:

  a vector or list

## Value

a character vector

We want to manipulate our config file from the command line AND preserve
comments. Unfortunately, the yaml C library does not parse comments and
it makes things difficult to handle. At the moment we have a hack where
we use whisker templates for these, but the drawback for whisker is that
it does not know how to handle lists, so it concatenates them with
commas:

    x <- c("a", "b", "c")
    hx <- list(hello = x)
    cat(yaml::as.yaml(hx)) # representation in yaml
    #> hello:
    #> - a
    #> - b
    #> - c
    cat(whisker::whisker.render("hello: {{hello}}", hx)) # messed up whisker
    #> hello: a,b,c

Moreover, we want to indicate that a yaml list is not a single key/value
pair so we want to enforce that we have

    key:
    - value1

and not

    key: value1

This converts the elements to a yaml list before it enters whisker and
makes sure that the values are clearly lists.

    hx[["hello"]] <- sandpaper:::yaml_list(hx[["hello"]])
    cat(whisker::whisker.render("hello: {{hello}}", hx)) # good whisker
    #> hello:
    #> - a
    #> - b
    #> - c

## Note

there IS a better solution than this hack, but for now, we will keep
what we are doing because it's okay for our purposes:
https://github.com/rstudio/blogdown/issues/560

## Examples

``` r
x <- c("a", "b", "c")
hx <- list(hello = x)
cat(yaml::as.yaml(hx)) # representation in yaml
#> hello:
#> - a
#> - b
#> - c
cat(whisker::whisker.render("hello: {{hello}}", hx)) # messed up whisker
#> hello: a,b,c
hx[["hello"]] <- sandpaper:::yaml_list(hx[["hello"]])
cat(whisker::whisker.render("hello: {{hello}}", hx)) # good whisker
#> hello: 
#> - a
#> - b
#> - c
```
