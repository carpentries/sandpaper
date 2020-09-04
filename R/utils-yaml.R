# Query only the yaml header. This is faster than slurping the entire file...
# useful for determining timings :)
politely_get_yaml <- function(path) {
  header <- readLines(path, n = 10, encoding = "UTF-8")
  barriers <- grep("^---$", header)
  if (length(barriers) == 0) {
    stop("No yaml header")
  }
  if (length(barriers) == 1) {
    to_skip <- 10L
    next_ten <- vector(mode = "character", length = 10)
    while (length(barriers) < 2) {
      next_ten <- scan(
        path, 
        what = character(),
        sep = "\n",
        skip = to_skip,
        nlines = 10,
        encoding = "UTF-8",
        quiet = TRUE,
        blank.lines.skip = FALSE,
        skipNul = FALSE
      )
      header <- c(header, next_ten)
      barriers <- grep("^---$", header)
      to_skip <- to_skip + 10L
    }
  }
  return(header[barriers[1]:barriers[2]])
}

yaml_writer <- function(yml, path) {
  # if this is null, no harm done
  header <- attr(yml, "header")
  yml <- yaml::as.yaml(
    yml, 
    handlers = list(POSIXct = UTC_timestamp)
  )
  writeLines(c(header, yml), path)
}

write_pkgdown_yaml <- function(yml, path) {
  yaml_writer(yml, path_site_yaml(path))
}

get_information_header <- function(yml) {
  last_pos   <- gregexpr("- information", yml, fixed = TRUE)[[1]][[2]]
  substring(yml, 1, last_pos + nchar("- information"))
}

# Returns a character vector of the yaml file with comments in tact
get_yaml_text <- function(path, collapse = TRUE) {
  out <- scan(
    path, 
    what = character(),
    sep = "\n",
    encoding = "UTF-8",
    quiet = TRUE,
    blank.lines.skip = FALSE,
    skipNul = FALSE
  )
  paste(out, collapse = "\n")
}

get_path_site_yaml <- function(path) {
  yml <- get_yaml_text(path_site_yaml(path))
  structure(yaml::yaml.load(yml), header = get_information_header(yml))
}
