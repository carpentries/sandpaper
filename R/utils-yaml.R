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

yaml_writer <- function(yaml, path) {
  # if this is null, no harm done
  header <- attr(yaml, "header")
  yaml <- yaml::as.yaml(
    yaml, 
    handlers = list(POSIXct = UTC_timestamp)
  )
  writeLines(c(header, yaml), path)
}

write_pkgdown_yaml <- function(yaml, path) {
  yaml_writer(yaml, path_site_yaml(path))
}

get_information_header <- function(yaml) {
  last_pos   <- gregexpr("- information", yaml, fixed = TRUE)[[1]][[2]]
  substring(yaml, 1, last_pos + nchar("- information"))
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
  yaml <- get_yaml_text(path_site_yaml(path))
  structure(yaml::yaml.load(yaml), header = get_information_header(yaml))
}
