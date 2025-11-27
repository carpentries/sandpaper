# Get the hash for the previous and current lockfile (as recorded in the lesson)

Get the hash for the previous and current lockfile (as recorded in the
lesson)

## Usage

``` r
renv_lockfile_hash(path, db_path, profile = "lesson-requirements")
```

## Arguments

- path:

  path to the lesson

- db_path:

  path to the database

- profile:

  name of the profile renv uses for the lesson requirements

## Value

a named list:

- old: hash value recoreded in the database

- new: hash value of the current file
