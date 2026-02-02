# Update file checksums to account for child documents

If any R Markdown file contains a child document, its hash will be
replaced with the hash of the combined and unnamed hashes of the parent
and descendants (aka the lineage).

## Usage

``` r
hash_children(checksums, files, lineage)

get_lineages(lsn)
```

## Arguments

- checksums:

  the hashes of the parent files

- files:

  the relative path of the parent files to the `root_path`

- lineage:

  a named list of character vectors specifying absolute paths for the
  full lineage of parent Markdown or R Markdown files (inclusive). The
  names will be the relative path of the parent.

- lsn:

  a
  [pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)
  object

## Value

- `get_lineages()` a named list of charcter vectors specifying the
  lineage of parent files. The names are the relative paths of the
  parents.

- `hash_children()` a character vector of hashes of the same length as
  the parent files.

## Details

When handling child files for lessons, it is important that changes in
child files will cause the source file to change as well.

- The `get_lineages()` function finds the child files from a
  [pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)
  object.

- Because we use a text database that relies on the hash of the file to
  determine if a file should be rebuilt, `hash_children()` piggybacks on
  this paradigm by assigning a unique hash to a parent file with
  children that is the hash of the vector of hashes of the files. The
  hash of hashes is created with
  [`rlang::hash()`](https://rlang.r-lib.org/reference/hash.html).

## Examples

``` r
# This demonstration will show how a temporary database can be set up. It
# will only work with a sandpaper lesson
# setup -----------------------------------------------------------------
# The setup needs to include an R Markdown file with a child file.
tmp <- tempfile()
on.exit(fs::dir_delete(tmp), add = TRUE)
#> Error: [ENOENT] Failed to search directory '/tmp/Rtmp4syuyP/file1cc7198b71a8': no such file or directory
create_lesson(tmp, rmd = FALSE, open = FALSE)
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ☐ Edit /tmp/Rtmp4syuyP/file1cc7198b71a8/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ✔ First episode created in /tmp/Rtmp4syuyP/file1cc7198b71a8/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> ✔ Lesson successfully created in /tmp/Rtmp4syuyP/file1cc7198b71a8
#> → Creating Lesson in /tmp/Rtmp4syuyP/file1cc7198b71a8...
#> /tmp/Rtmp4syuyP/file1cc7198b71a8
# get namespace to use internal functions
sp <- asNamespace("sandpaper")
db <- fs::path(tmp, "site/built/md5sum.txt")
resources <- fs::path(tmp, c("episodes/introduction.md", "index.md"))
# create child file
writeLines("Hello from another file!\n",
  fs::path(tmp, "episodes", "files", "hi.md"))
# use child file
cat("\n\n```{r child='files/hi.md'}\n```\n",
  file = resources[[1]], append = TRUE)
# convert to Rmd
fs::file_move(resources[[1]], fs::path_ext_set(resources[[1]], "Rmd"))
resources[[1]] <- fs::path_ext_set(resources[[1]], "Rmd")
set_episodes(tmp, fs::path_file(resources[[1]]), write = TRUE)

# get_lineages ------------------------------------------------------
# we can get the child files by scanning the Lesson object
lsn <- sp$this_lesson(tmp)
class(lsn)
#> [1] "Lesson" "R6"    
children <- sp$get_lineages(lsn)
print(children)
#> $`episodes/introduction.Rmd`
#> [1] "/tmp/Rtmp4syuyP/file1cc7198b71a8/episodes/introduction.Rmd"
#> [2] "/tmp/Rtmp4syuyP/file1cc7198b71a8/episodes/files/hi.md"     
#> 
#> $CODE_OF_CONDUCT.md
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/CODE_OF_CONDUCT.md
#> 
#> $CONTRIBUTING.md
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/CONTRIBUTING.md
#> 
#> $LICENSE.md
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/LICENSE.md
#> 
#> $README.md
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/README.md
#> 
#> $index.md
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/index.md
#> 
#> $links.md
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/links.md
#> 
#> $`instructors/instructor-notes.md`
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/instructors/instructor-notes.md
#> 
#> $`learners/reference.md`
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/learners/reference.md
#> 
#> $`learners/setup.md`
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/learners/setup.md
#> 
#> $`profiles/learner-profiles.md`
#> /tmp/Rtmp4syuyP/file1cc7198b71a8/profiles/learner-profiles.md
#> 

# hash_children ---------------------------------------------------
# get hash of parent
phash <- tools::md5sum(resources[[1]])
rel_parent <- fs::path_rel(resources[[1]], start = tmp)
sp$hash_children(phash, rel_parent, children)
#>          episodes/introduction.Rmd 
#> "f0803606fb41fb5ba9d03df618d492ae" 
# demonstrate how this works ----------------
# the combined hashes have their names removed and then `rlang::hash()`
# creates the hash of the unnamed hashes.
chash <- tools::md5sum(children[[1]])
hashes <- unname(chash)
print(hashes)
#> [1] "4c6b9769ec953e27d83c6c707d549b82"
#> [2] "a649c757324fc9c289e38f3d77c206d5"
rlang::hash(hashes)
#> [1] "f0803606fb41fb5ba9d03df618d492ae"
```
