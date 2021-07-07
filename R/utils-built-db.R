#' Get the expected hash from a set of built files
#'
#' @param path path to at least one generated markdown file
#' @param db the path to the text database
#' @return a character vector of checksums
#' @keywords internal
#' @seealso [build_status()], [get_built_db()]
get_hash <- function(path, db = fs::path(path_built(path), "md5sum.txt")) {
  opt = options(stringsAsFactors = FALSE)
  on.exit(options(opt), add = TRUE)
  db <- read.table(db, header = TRUE)
  db$checksum[fs::path_file(db$built) %in% fs::path_file(path)]
}

#' Get the database of built files and their hashes
#'
#' @param db the path to the database.
#' @param filter regex describing files to include. 
#' @return a data frame with three columns:
#'   - file: the path to the source file
#'   - checksum: the hash of the source file to generate the built file
#'   - built: the path to the built file 
#' @keywords internal
#' @seealso [build_status()], [get_hash()]
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

write_build_db <- function(md5, db) write.table(md5, db, row.names = FALSE)

#' Identify what files need to be rebuilt
#'
#' @param sources a character vector of ALL source files. 
#' @param db the path to the database
#' @param rebuild if the files should be rebuilt, set this to TRUE (defaults to
#'   FALSE)
#' @param write if TRUE, the database will be updated, Defaults to FALSE, meaning that the database will remain the same. 
#' @keywords internal
#' @seealso [get_resource_list()], [get_built_db()], [get_hash()]
build_status <- function(sources, db = "site/built/md5sum.txt", rebuild = FALSE, write = FALSE) {
  # Modified on 2021-03-10 from blogdown::filter_md5sum version 1.2
  # Original author: Yihui Xie
  # My additional commands use arrows.
  opt = options(stringsAsFactors = FALSE)
  on.exit(options(opt), add = TRUE)
  # To make this portable, we want to record relative paths. The sources coming
  # in will be absolute paths, so this will check for the common path and then
  # trim it.
  root_path  <- fs::path_common(sources)
  sources    <- fs::path_rel(sources, start = root_path)
  built_path <- fs::path_rel(fs::path_dir(db), root_path)
  # built files are flattened here
  built <- fs::path(built_path, fs::path_file(sources))
  built <- ifelse(
    fs::path_ext(built) %nin% c("yaml", "yml"),
    fs::path_ext_set(built, "md"), built
  )
  md5 = data.frame(
    file     = sources,
    checksum = tools::md5sum(fs::path(root_path, sources)),
    built    = built
  )
  if (!file.exists(db)) {
    fs::dir_create(dirname(db))
    if (write)
      write_build_db(md5, db)
    return(list(build = fs::path(root_path, sources), new = md5))
  }
  # old checksums (2 columns: file path and checksum)
  old = read.table(db, header = TRUE)
  one = merge(md5, old, 'file', all = TRUE, suffixes = c('', '.old'), sort = FALSE)
  newsum <- names(one)[2]
  oldsum <- paste0(newsum, ".old")
  # Find the files that need to be removed because they don't exist anymore.
  to_remove <- one[['built.old']][is.na(one[[newsum]])]
  # merge destroys the order, so we need to reset it. Consequently, it will
  # also remove the files that no longer exist in the sources list.
  one <- one[match(sources, one$file), , drop = FALSE]
  if (rebuild) {
    files = one[['file']]
    to_remove <- old[['built']]
  } else {
    # exclude files if checksums are not changed
    unchanged <- one[[newsum]] == one[[oldsum]]
    files = setdiff(sources, one[['file']][unchanged])
  }
  if (write)
    write_build_db(one[, 1:3], db)

  # files and to_remove need absolute paths so that subprocesses can run them
  files     <- fs::path_abs(files, start = root_path)
  to_remove <- fs::path_abs(to_remove, start = root_path)

  list(
    build = files,
    remove = to_remove,
    new = one[, 1:3],
    old = old
  )
}


