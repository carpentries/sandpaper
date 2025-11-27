# Lesson Runtime Dependency Management

A customized provisioner for Carpentries Lessons based on renv that will
install and maintain the requirements for the lesson while *respecting
user environments*. This setup leads to several advantages:

- **reliable setup**: the version of the lesson built on the carpentries
  website will be the same as what you build on your computer because
  the packages will be identical

- **environmentally friendly**: The lesson dependencies are NOT stored
  in your default R library and they will not alter your R environment.

- **transparent**: any additions or deletions to the cache will be
  recorded in the lockfile, which is tracked by git.

The functions that control this cache are the following:

1.  `manage_deps()`: Creates and updates the dependencies in your
    lesson. If no lockfile exists in your lesson, this will create one
    for you.

2.  `update_cache()`: fetches updates for the dependencies and applies
    them to your cache and lockfile.

This is a wrapper around
[`renv::record()`](https://rstudio.github.io/renv/reference/record.html),
which helps you record a package or set of packages in your lockfile. It
can be useful when you want to upgrade or downgrade a specific package.

## Usage

``` r
manage_deps(
  path = ".",
  profile = "lesson-requirements",
  snapshot = TRUE,
  quiet = FALSE,
  use_site_libs = FALSE
)

update_cache(
  path = ".",
  profile = "lesson-requirements",
  prompt = interactive(),
  quiet = !prompt,
  snapshot = TRUE
)

pin_version(records = NULL, profile = "lesson-requirements", path = ".")
```

## Arguments

- path:

  path to your lesson. Defaults to the current working directory.

- profile:

  default to the profile for the lesson. Defaults to
  `lesson-requirements`. Only use this if you know what you are doing.

- snapshot:

  if `TRUE`, packages from the cache are added to the lockfile
  (default). Setting this to `FALSE` will add packages to the cache and
  not snapshot them.

- quiet:

  if `TRUE`, output will be suppressed, defaults to `FALSE`, providing
  output about different steps in the process of updating the local
  dependencies.

- use_site_libs:

  if `TRUE`, renv will include R_LIBS_SITE packages, defaults to
  `FALSE`. This is mostly useful when using the Workbench Docker
  container.

- prompt:

  if `TRUE`, a message will show you the packages that will be updated
  in your lockfile and ask for your permission. This is the default if
  it's running in an interactive session.

- records:

  a character vector or list of packages/resources to include in the
  lockfile. The most common way to do this is to use the
  `[package]@[version]` syntax (e.g. `gert@0.1.3`), but there are other
  specifications where you can specify the remote repository. See
  [`renv::record()`](https://rstudio.github.io/renv/reference/record.html)
  for details.

## Value

if `snapshot = TRUE`, a nested list representing the lockfile will be
returned.

the contents of the lockfile, invisibly

## Details

The renv package provides a very useful interface to bring one aspect of
reproducibility to R projects. Because people working on Carpentries
lessons are also working academics and will likely have projects on
their computer where the package versions are necessary for their work,
it's important that those environments are respected.

Our flavor of `{renv}` applies a package cache explicitly to the content
of the lesson, but does not impose itself as the default `{renv}`
environment.

This provisioner will do the following steps:

1.  check for consent to use the package cache via
    [`use_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
    and prompt for it if needed

2.  check if the profile has been created and create it if needed via
    [`renv::init()`](https://rstudio.github.io/renv/reference/init.html)

3.  populate the cache with packages needed from the user's system and
    download any that are missing via
    [`renv::hydrate()`](https://rstudio.github.io/renv/reference/hydrate.html).
    This includes all new packages that have been added to the lesson.

4.  If there is a lockfile already present, make sure the packages in
    the cache are aligned with the lockfile (downloading sources if
    needed) via
    [`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html).

5.  Record the state of the cache in a lockfile tracked by git. This
    will include adding new packages and removing old packages.
    [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)

When the lockfile changes, you will see it in git and have the power to
either commit or restore those changes.

## See also

[`use_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
and
[`no_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
for turning on and off the package cache, respectively.
