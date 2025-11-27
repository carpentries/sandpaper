# Filter reserved markdown files from the built db

This provides a service for
[`build_site()`](https://carpentries.github.io/sandpaper/dev/reference/build_site.md)
so that it does not build files that are used for aggregation, resource
provision, or GitHub specific files

## Usage

``` r
reserved_db(db)
```

## Arguments

- db:

  the database from
  [`get_built_db()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)

## Value

the same database with the above files filtered out

## Details

There are three types of files that are reserved and we do not want to
propogate to the HTML site

### GitHub specific files

These are the README and CONTRIBUTING files. Both of these files provide
information that is useful only in the context of GitHub

### Aggregation files

These are files that are aggregated together with other files or have
content appended to them:

- `index` and `learners/setup` are concatenated

- all markdown files in `profiles/` are concatenated

- `instructors/instructor-notes` have the inline instructor notes
  concatenated.

### Resource provision files

At the moment, there is one file that we use for resource provision and
should not be propogated to the site: `links`. This provides global
links for the lesson. It provides no content in and of itself.

## See also

[`get_built_db()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)
that provides the database and
[`build_site()`](https://carpentries.github.io/sandpaper/dev/reference/build_site.md),
which uses the function
