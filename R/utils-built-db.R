#' @param path path to at least one generated markdown file
#' @param db the path to the text database
#' @keywords internal
#' @rdname build_status
get_hash <- function(path, db = fs::path(path_built(path), "md5sum.txt")) {
  opt = options(stringsAsFactors = FALSE)
  on.exit(options(opt), add = TRUE)
  db <- get_built_db(db, filter = "*")
  db$checksum[fs::path_file(db$built) %in% fs::path_file(path)]
}

#' @param db the path to the database.
#' @param filter regex describing files to include.
#' @keywords internal
#' @rdname build_status
get_built_db <- function(db = "site/built/md5sum.txt", filter = "*R?md") {
  opt <- options(stringsAsFactors = FALSE)
  on.exit(options(opt), add = TRUE)
  if (!file.exists(db)) {
    # no markdown files have been built yet
    return(data.frame(file = character(0), checksum = character(0), built = character(0)))
  }
  files <- read.table(db, header = TRUE)
  are_markdown <- grepl(filter, fs::path_ext(files[["file"]]))
  return(files[are_markdown, , drop = FALSE])
}

#' Filter reserved markdown files from the built db
#'
#' This provides a service for `build_site()` so that it does not build files
#' that are used for aggregation, resource provision, or GitHub specific files
#'
#' @details
#'
#' There are three types of files that are reserved and we do not want to
#' propogate to the HTML site
#'
#' ## GitHub specific files
#'
#' These are the README and CONTRIBUTING files. Both of these files provide
#' information that is useful only in the context of GitHub
#'
#' ## Aggregation files
#'
#' These are files that are aggregated together with other files or have
#' content appended to them:
#'
#'  - `index` and `learners/setup` are concatenated
#'  - all markdown files in `profiles/` are concatenated
#'  - `instructors/instructor-notes` have the inline instructor notes
#'     concatenated.
#'
#' ## Resource provision files
#'
#' At the moment, there is one file that we use for resource provision and
#' should not be propogated to the site: `links`. This provides global links
#' for the lesson. It provides no content in and of itself.
#'
#' @param db the database from [get_built_db()]
#' @return the same database with the above files filtered out
#' @keywords internal
#' @seealso [get_built_db()] that provides the database and [build_site()],
#'   which uses the function
reserved_db <- function(db) {
  reserved <- c("index", "README", "CONTRIBUTING", "learners/setup",
    "profiles[/].*", "instructors[/]instructor-notes[.]*", "links")
  reserved <- paste(reserved, collapse = "|")
  reserved <- paste0("^(", reserved, ")[.]R?md")
  db[!grepl(reserved, db$file, perl = TRUE), , drop = FALSE]
}

write_build_db <- function(md5, db) write.table(md5, db, row.names = FALSE)

#' Update file checksums to account for child documents
#'
#' @description
#'
#' If any R Markdown file contains a child document, its hash will be replaced
#' with the hash of the combined and unnamed hashes of the parent and
#' descendants (aka the lineage).
#'
#' @details
#'
#' When handling child files for lessons, it is important that changes in child
#' files will cause the source file to change as well.
#'
#'  - The `get_lineages()` function finds the child files from a
#'    [pegboard::Lesson] object.
#'  - Because we use a text database that relies on the hash of the file to
#'    determine if a file should be rebuilt, `hash_children()` piggybacks
#'    on this paradigm by assigning a unique hash to a parent file with
#'    children that is the hash of the vector of hashes of the files. The hash
#'    of hashes is created with `rlang::hash()`.
#'
#' @param checksums the hashes of the parent files
#' @param files the relative path of the parent files to the `root_path`
#' @param lineage a named list of character vectors specifying absolute paths
#'   for the full lineage of parent Markdown or R Markdown files (inclusive).
#'   The names will be the relative path of the parent.
#' @return
#'   - `get_lineages()` a named list of charcter vectors specifying the
#'      lineage of parent files. The names are the relative paths of the
#'      parents.
#'   - `hash_children()` a character vector of hashes of the same length
#'      as the parent files.
#' @keywords internal
#' @rdname hash_children
#' @examples
#' # This demonstration will show how a temporary database can be set up. It
#' # will only work with a sandpaper lesson
#' # setup -----------------------------------------------------------------
#' # The setup needs to include an R Markdown file with a child file.
#' tmp <- tempfile()
#' on.exit(fs::dir_delete(tmp), add = TRUE)
#' create_lesson(tmp, rmd = FALSE, open = FALSE)
#' # get namespace to use internal functions
#' sp <- asNamespace("sandpaper")
#' db <- fs::path(tmp, "site/built/md5sum.txt")
#' resources <- fs::path(tmp, c("episodes/introduction.md", "index.md"))
#' # create child file
#' writeLines("Hello from another file!\n",
#'   fs::path(tmp, "episodes", "files", "hi.md"))
#' # use child file
#' cat("\n\n```{r child='files/hi.md'}\n```\n",
#'   file = resources[[1]], append = TRUE)
#' # convert to Rmd
#' fs::file_move(resources[[1]], fs::path_ext_set(resources[[1]], "Rmd"))
#' resources[[1]] <- fs::path_ext_set(resources[[1]], "Rmd")
#' set_episodes(tmp, fs::path_file(resources[[1]]), write = TRUE)
#'
#' # get_lineages ------------------------------------------------------
#' # we can get the child files by scanning the Lesson object
#' lsn <- sp$this_lesson(tmp)
#' class(lsn)
#' children <- sp$get_lineages(lsn)
#' print(children)
#'
#' # hash_children ---------------------------------------------------
#' # get hash of parent
#' phash <- tools::md5sum(resources[[1]])
#' rel_parent <- fs::path_rel(resources[[1]], start = tmp)
#' sp$hash_children(phash, rel_parent, children)
#' # demonstrate how this works ----------------
#' # the combined hashes have their names removed and then `rlang::hash()`
#' # creates the hash of the unnamed hashes.
#' chash <- tools::md5sum(children[[1]])
#' hashes <- unname(chash)
#' print(hashes)
#' rlang::hash(hashes)
hash_children <- function(checksums, files, lineage) {
  res <- checksums
  names(res) <- files
  for (i in files) {
    this_lineage <- lineage[[i]]
    # No children exist under the following conditions
    #   0: the file is not a markdown file, so it is NULL from the above
    #   1: the file really has no children
    no_children <- length(this_lineage) <= 1L
    if (no_children) {
      next
    }
    hashes <- unname(c(res[[i]], tools::md5sum(this_lineage[-1L])))
    res[[i]] <- rlang::hash(hashes)
  }
  return(res)
}

# Return list of child nodes used in each file
#' @rdname hash_children
#' @param lsn a [pegboard::Lesson] object
get_lineages <- function(lsn) {
  # lineages are the parent file followed by the subsequent children
  lineages <- lapply(c(lsn$episodes, lsn$extra), function(ep) {
      lsn$trace_lineage(ep$path)
    }
  )
  # We need to set the names to the relative path to match our file inputs
  names(lineages) <- vapply(lineages,
    FUN = function(l, p) {
      fs::path_rel(l[1], start = p)
    },
    FUN.VALUE = character(1),
    p = lsn$path
  )
  return(lineages)
}

#' Identify what files need to be rebuilt and what need to be removed
#'
#' `build_status()` takes in a vector of files and compares them against a text
#' database of files with checksums. It's been heavily adapted from blogdown to
#' provide utilities for removal and updating of the old database.
#'
#' `get_built_db()` returns the text database, which you can filter on
#'
#' `get_hash()` should probably be named `get_expected_hash()` because it will
#' return the expected hash of a given file from the database
#'
#' @details
#'
#' If you supply a single file into this function, we assume that you want that
#' one file to be rebuilt, so we will _always_ return that file in the `$build`
#' element and update the md5 sum in the database (if it has changed at all).
#'
#' If you supply multiple files, you are indicating that these are the _only_
#' files you care about and the database will be updated accordingly, removing
#' entries missing from the sources.
#'
#' @param sources a character vector of ALL source files OR a single file to be
#'   rebuilt. These must be *absolute paths*
#' @param db the path to the database
#' @param rebuild if the files should be rebuilt, set this to TRUE (defaults to
#'   FALSE)
#' @param write if TRUE, the database will be updated, Defaults to FALSE,
#' meaning that the database will remain the same.
#' @return a list of the following elements
#'   - *build* absolute paths of files to build
#'   - *new* a new data frame with three columns:
#'      - file the relative path to the source file
#'      - checksum the md5 sum of the source file
#'      - built the relative path to the built file
#'      - date the date a file was last updated/built
#'   - *remove* absolute paths of files to remove. This will be missing if there
#'      is nothing to remove
#'   - *old* old database (for debugging). This will be missing if there is no
#'     old database or if a single file was rebuilt.
#' @keywords internal
#' @rdname build_status
#' @seealso [get_resource_list()], [reserved_db()], [hash_children()]
#' @examples
#' # This demonstration will show how a temporary database can be set up. It
#' # will only work with a sandpaper lesson
#' # setup -----------------------------------------------------------------
#' tmp <- tempfile()
#' on.exit(fs::dir_delete(tmp), add = TRUE)
#' create_lesson(tmp, rmd = FALSE, open = FALSE)
#'
#' # show build status -----------------------------------------------------
#' # get namespace to use internal functions
#' sp <- asNamespace("sandpaper")
#' db <- fs::path(tmp, "site/built/md5sum.txt")
#' resources <- fs::path(tmp, c("episodes/introduction.md", "index.md"))
#' # first run, everything needs to be built and no build file exists
#' sp$build_status(resources, db, write = TRUE)
#' # second run, everything is identical and nothing to be rebuilt
#' sp$build_status(resources, db, write = TRUE)
#' # this is because the db exists on disk and you can query it
#' sp$get_built_db(db, filter = "*")
#' sp$get_built_db(db, filter = "*R?md")
#' # if you get the hash of the file, it's equal to the expected:
#' print(actual <- tools::md5sum(resources[[1]]))
#' print(expected <- sp$get_hash(resources[[1]], db))
#' unname(actual == expected)
#'
#' # replaced files need to be rebuilt -------------------------------------
#' # if we change the introduction to an R Markdown file, the build will
#' # see this as a deleted file and re-added file.
#' cat("This is now an R Markdown document and the time is `r Sys.time()`\n",
#'   file = resources[[1]], append = TRUE)
#' fs::file_move(resources[[1]], fs::path_ext_set(resources[[1]], "Rmd"))
#' resources[[1]] <- fs::path_ext_set(resources[[1]], "Rmd")
#' set_episodes(tmp, fs::path_file(resources[[1]]), write = TRUE)
#' sp$build_status(resources, db, write = TRUE)
#'
#' # modified files need to be rebuilt -------------------------------------
#' cat("We are using `r R.version.string`\n",
#'   file = resources[[1]], append = TRUE)
#' sp$build_status(resources, db, write = TRUE)
#'
#' # child files require rebuilding ----------------------------------------
#' writeLines("Hello from another file!\n",
#'   fs::path(tmp, "episodes", "files", "hi.md"))
#' cat("\n\n```{r child='files/hi.md'}\n```\n",
#'   file = resources[[1]], append = TRUE)
#' sp$build_status(resources, db, write = TRUE)
#' # NOTE: for child files, the checksums are the checksum of the checksums
#' # of the parent and children, so the file checksum may not make sense
#'
#' # changing a child file rebuilds the parent ----------------------------
#' cat("Goodbye!\n", append = TRUE,
#'   file = fs::path(tmp, "episodes", "files", "hi.md"))
#' sp$build_status(resources, db, write = TRUE)
build_status <- function(sources, db = "site/built/md5sum.txt", rebuild = FALSE, write = FALSE) {
  # Modified on 2021-03-10 from blogdown::filter_md5sum version 1.2
  # Original author: Yihui Xie
  # My additional commands use arrows.
  opt = options(stringsAsFactors = FALSE)
  on.exit(options(opt), add = TRUE)
  # To make this portable, we want to record relative paths. The sources coming
  # in will be absolute paths, so this will check for the common path and then
  # trim it.
  build_one <- length(sources) == 1L

  # If we have a single source passed in, this means that we want to update it
  # in the database and force it to rebuild
  root_path <- root_path(fs::path_common(sources)) # ensure we're at the actual lesson root path
  sources    <- fs::path_rel(sources, start = root_path)

  built_path <- fs::path_rel(fs::path_dir(db), root_path)
  # built files are flattened here
  built <- fs::path(built_path, fs::path_file(sources))
  built <- ifelse(
    fs::path_ext(built) %in% c("Rmd", "rmd"),
    fs::path_ext_set(built, "md"), built
  )
  date <- format(Sys.Date(), "%F")
  # calculate checksums -------------------------------------------------------
  checksums <- tools::md5sum(fs::path(root_path, sources))
  # if there are any RMD documents, we check for child documents
  is_rmd <- tolower(fs::path_ext(sources)) == "rmd"
  if (any(is_rmd)) {
    children <- get_lineages(this_lesson(root_path))
  } else {
    children <- list()
  }
  children_exist <- length(children) > 0L && any(lengths(children) > 1L)
  if (children_exist) {
    # update the checksums of the parent
    # using rlang::hash(sumparent, sumchild, ...)
    checksums <- hash_children(checksums, sources, children)
  }
  md5 = data.frame(
    file     = sources,
    checksum = checksums,
    built    = built,
    date     = date,
    stringsAsFactors = FALSE
  )

  no_db_yet <- !file.exists(db)
  if (no_db_yet) {
    fs::dir_create(dirname(db))
    md5$date <- date
    if (write)
      write_build_db(md5, db)
    return(list(build = fs::path(root_path, sources), new = md5))
  }
  # old checksums (2 columns: file path and checksum)
  old = read.table(db, header = TRUE)
  # insert current date if it does not exist
  old <- if (is.null(old$date)) data.frame(old, list(date = date), stringsAsFactors = FALSE) else old
  # BUILD ONLY ONE FILE --------------------------------------------------------
  if (build_one) {
    new <- old
    to_build <- old$file == md5$file
    if (any(to_build)) {
      new$checksum[to_build] <- md5$checksum
      new$built[to_build]    <- md5$built
    } else {
      new <- rbind(old, md5)
    }
    return(list(build = fs::path(root_path, sources), new = new))
  }
  # FILTERING ------------------------------------------------------------------
  #
  # Here we determine the files to keep and the files to remove. This creates
  # a 7-column data frame that contains the following fields:
  #
  # 1. file - the data merged on the file name
  # 2. checksum, the NEW checksum values for these files (NA if the file no
  #    no longer exists)
  # 3. built the relative path to the built file (NA if the file no longer exists)
  # 4. date today's date
  # 5. checksum.old the old checksum values
  # 6. built.old the old built path
  # 7. date.old the date the files were previously built
  one = merge(md5, old, 'file', all = TRUE, suffixes = c('', '.old'), sort = FALSE)
  newsum <- names(one)[2]
  oldsum <- paste0(newsum, ".old")
  # Find the files that need to be removed because they don't exist anymore.
  # TODO: add a switch to _not_ remove these files, because we want to rebuild
  #       a subset of the files.
  to_remove <- one[['built.old']][is.na(one[[newsum]])]
  # merge destroys the order, so we need to reset it. Consequently, it will
  # also remove the files that no longer exist in the sources list.
  one <- one[match(sources, one$file), , drop = FALSE]
  # TODO: see if we can have rebuild be a vector matching the sources so that
  #       we can indicate a vector of files to rebuild.
  if (rebuild) {
    files = one[['file']]
    to_remove <- old[['built']]
  } else {
    # exclude files from the build order if checksums are not changed
    unchanged <- one[[newsum]] == one[[oldsum]]
    # do not overwrite the dates
    one[["date"]][which(unchanged)] <- one[["date.old"]][which(unchanged)]
    files = setdiff(sources, one[['file']][unchanged])
  }
  if (write) {
    write_build_db(one[, 1:4], db)
  }
  # files and to_remove need absolute paths so that subprocesses can run them
  files     <- fs::path_abs(files, start = root_path)
  to_remove <- fs::path_abs(to_remove, start = root_path)

  list(
    build = files,
    remove = to_remove,
    new = one[, 1:4],
    old = old
  )
}


