# Identify what files need to be rebuilt and what need to be removed

`build_status()` takes in a vector of files and compares them against a
text database of files with checksums. It's been heavily adapted from
blogdown to provide utilities for removal and updating of the old
database.

## Usage

``` r
get_hash(path, db = fs::path(path_built(path), "md5sum.txt"))

get_built_db(db = "site/built/md5sum.txt", filter = "*R?md")

build_status(
  sources,
  db = "site/built/md5sum.txt",
  rebuild = FALSE,
  write = FALSE
)
```

## Arguments

- path:

  path to at least one generated markdown file

- db:

  the path to the database

- filter:

  regex describing files to include.

- sources:

  a character vector of ALL source files OR a single file to be rebuilt.
  These must be *absolute paths*

- rebuild:

  if the files should be rebuilt, set this to TRUE (defaults to FALSE)

- write:

  if TRUE, the database will be updated, Defaults to FALSE, meaning that
  the database will remain the same.

## Value

a list of the following elements

- *build* absolute paths of files to build

- *new* a new data frame with three columns:

  - file the relative path to the source file

  - checksum the md5 sum of the source file

  - built the relative path to the built file

  - date the date a file was last updated/built

- *remove* absolute paths of files to remove. This will be missing if
  there is nothing to remove

- *old* old database (for debugging). This will be missing if there is
  no old database or if a single file was rebuilt.

## Details

`get_built_db()` returns the text database, which you can filter on

`get_hash()` should probably be named `get_expected_hash()` because it
will return the expected hash of a given file from the database

If you supply a single file into this function, we assume that you want
that one file to be rebuilt, so we will *always* return that file in the
`$build` element and update the md5 sum in the database (if it has
changed at all).

If you supply multiple files, you are indicating that these are the
*only* files you care about and the database will be updated
accordingly, removing entries missing from the sources.

## See also

[`get_resource_list()`](https://carpentries.github.io/sandpaper/reference/get_resource_list.md),
[`reserved_db()`](https://carpentries.github.io/sandpaper/reference/reserved_db.md),
[`hash_children()`](https://carpentries.github.io/sandpaper/reference/hash_children.md)

## Examples

``` r
# This demonstration will show how a temporary database can be set up. It
# will only work with a sandpaper lesson
# setup -----------------------------------------------------------------
tmp <- tempfile()
on.exit(fs::dir_delete(tmp), add = TRUE)
#> Error: [ENOENT] Failed to search directory '/tmp/RtmpfD9rhg/file193963297124': no such file or directory
create_lesson(tmp, rmd = FALSE, open = FALSE)
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ☐ Edit /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ✔ First episode created in /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> ✔ Lesson successfully created in /tmp/RtmpfD9rhg/file193963297124
#> → Creating Lesson in /tmp/RtmpfD9rhg/file193963297124...
#> /tmp/RtmpfD9rhg/file193963297124

# show build status -----------------------------------------------------
# get namespace to use internal functions
sp <- asNamespace("sandpaper")
db <- fs::path(tmp, "site/built/md5sum.txt")
resources <- fs::path(tmp, c("episodes/introduction.md", "index.md"))
# first run, everything needs to be built and no build file exists
sp$build_status(resources, db, write = TRUE)
#> $build
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md
#> /tmp/RtmpfD9rhg/file193963297124/index.md
#> 
#> $new
#>                                                                               file
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md episodes/introduction.md
#> /tmp/RtmpfD9rhg/file193963297124/index.md                                 index.md
#>                                                                                   checksum
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md fd46501f174bb7e6cc280a1436fbc12a
#> /tmp/RtmpfD9rhg/file193963297124/index.md                 a02c9c785ed98ddd84fe3d34ddb12fcd
#>                                                                                built
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md site/built/introduction.md
#> /tmp/RtmpfD9rhg/file193963297124/index.md                        site/built/index.md
#>                                                                 date
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md 2025-12-03
#> /tmp/RtmpfD9rhg/file193963297124/index.md                 2025-12-03
#> 
# second run, everything is identical and nothing to be rebuilt
sp$build_status(resources, db, write = TRUE)
#> $build
#> character(0)
#> 
#> $remove
#> character(0)
#> 
#> $new
#>                       file                         checksum
#> 1 episodes/introduction.md fd46501f174bb7e6cc280a1436fbc12a
#> 2                 index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
#> $old
#>                       file                         checksum
#> 1 episodes/introduction.md fd46501f174bb7e6cc280a1436fbc12a
#> 2                 index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
# this is because the db exists on disk and you can query it
sp$get_built_db(db, filter = "*")
#>                       file                         checksum
#> 1 episodes/introduction.md fd46501f174bb7e6cc280a1436fbc12a
#> 2                 index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
sp$get_built_db(db, filter = "*R?md")
#>                       file                         checksum
#> 1 episodes/introduction.md fd46501f174bb7e6cc280a1436fbc12a
#> 2                 index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
# if you get the hash of the file, it's equal to the expected:
print(actual <- tools::md5sum(resources[[1]]))
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.md 
#>                        "fd46501f174bb7e6cc280a1436fbc12a" 
print(expected <- sp$get_hash(resources[[1]], db))
#> [1] "fd46501f174bb7e6cc280a1436fbc12a"
unname(actual == expected)
#> [1] TRUE

# replaced files need to be rebuilt -------------------------------------
# if we change the introduction to an R Markdown file, the build will
# see this as a deleted file and re-added file.
cat("This is now an R Markdown document and the time is `r Sys.time()`\n",
  file = resources[[1]], append = TRUE)
fs::file_move(resources[[1]], fs::path_ext_set(resources[[1]], "Rmd"))
resources[[1]] <- fs::path_ext_set(resources[[1]], "Rmd")
set_episodes(tmp, fs::path_file(resources[[1]]), write = TRUE)
sp$build_status(resources, db, write = TRUE)
#> $build
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.Rmd
#> 
#> $remove
#> /tmp/RtmpfD9rhg/file193963297124/site/built/introduction.md
#> 
#> $new
#>                        file                         checksum
#> 2 episodes/introduction.Rmd 42f28ae9ac714f87eb912bfccf614cab
#> 1                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 2 site/built/introduction.md 2025-12-03
#> 1        site/built/index.md 2025-12-03
#> 
#> $old
#>                       file                         checksum
#> 1 episodes/introduction.md fd46501f174bb7e6cc280a1436fbc12a
#> 2                 index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 

# modified files need to be rebuilt -------------------------------------
cat("We are using `r R.version.string`\n",
  file = resources[[1]], append = TRUE)
sp$build_status(resources, db, write = TRUE)
#> $build
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.Rmd
#> 
#> $remove
#> character(0)
#> 
#> $new
#>                        file                         checksum
#> 1 episodes/introduction.Rmd 700f007bdd7e8fd6e3f7011f80dacf7b
#> 2                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
#> $old
#>                        file                         checksum
#> 1 episodes/introduction.Rmd 42f28ae9ac714f87eb912bfccf614cab
#> 2                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 

# child files require rebuilding ----------------------------------------
writeLines("Hello from another file!\n",
  fs::path(tmp, "episodes", "files", "hi.md"))
cat("\n\n```{r child='files/hi.md'}\n```\n",
  file = resources[[1]], append = TRUE)
sp$build_status(resources, db, write = TRUE)
#> $build
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.Rmd
#> 
#> $remove
#> character(0)
#> 
#> $new
#>                        file                         checksum
#> 1 episodes/introduction.Rmd 4a0b39645c21579d9992ad3b50d623e4
#> 2                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
#> $old
#>                        file                         checksum
#> 1 episodes/introduction.Rmd 700f007bdd7e8fd6e3f7011f80dacf7b
#> 2                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
# NOTE: for child files, the checksums are the checksum of the checksums
# of the parent and children, so the file checksum may not make sense

# changing a child file rebuilds the parent ----------------------------
cat("Goodbye!\n", append = TRUE,
  file = fs::path(tmp, "episodes", "files", "hi.md"))
sp$build_status(resources, db, write = TRUE)
#> $build
#> /tmp/RtmpfD9rhg/file193963297124/episodes/introduction.Rmd
#> 
#> $remove
#> character(0)
#> 
#> $new
#>                        file                         checksum
#> 1 episodes/introduction.Rmd 2ab510dfa3fbd1f224ab3c20547391ea
#> 2                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
#> $old
#>                        file                         checksum
#> 1 episodes/introduction.Rmd 4a0b39645c21579d9992ad3b50d623e4
#> 2                  index.md a02c9c785ed98ddd84fe3d34ddb12fcd
#>                        built       date
#> 1 site/built/introduction.md 2025-12-03
#> 2        site/built/index.md 2025-12-03
#> 
```
