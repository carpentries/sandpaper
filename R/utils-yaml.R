# Query only the yaml header. This is faster than slurping the entire file...
# useful for determining timings :)
politely_get_yaml <- function(path) {
  header <- readLines(path, n = 10, encoding = "UTF-8")
  barriers <- grep("^---$", header)
  if (length(barriers) == 0) {
    # we don't need to warn if they are scanning an index.md with no yaml
    if (fs::path_file(path) != "index.md") {
      thm <- cli::cli_div(theme = sandpaper_cli_theme())
      cli::cli_alert_danger("No yaml header found in the first 10 lines of {path}")
      cli::cli_end(thm)
    }
    return(character(0))
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

siQuote <- function(string) {
  string <- as.character(string)
  empty <- length(string) == 0 || identical(string, "")
  ok <- !empty && (
    startsWith(string, "'") && endsWith(string, "'") ||
    startsWith(string, '"') && endsWith(string, '"')
  )
  if (ok) {
    string
  } else if (empty) {
    ""
  } else if (!any(grepl("'", string))) {
    paste0("'", string, "'")
  } else {
    paste0('"', gsub("(?<![\\\\])[\"]", "\\\\\"", string, perl = TRUE), '"')
  }
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


#' Create a valid, opinionated yaml list for insertion into a whisker template
#'
#' @param thing a vector or list
#' @return a character vector
#'
#' We want to manipulate our config file from the command line AND preserve
#' comments. Unfortunately, the yaml C library does not parse comments and it
#' makes things difficult to handle. At the moment we have a hack where we use
#' whisker templates for these, but the drawback for whisker is that it does not
#' know how to handle lists, so it concatenates them with commas:
#'
#' ```{r}
#' x <- c("a", "b", "c")
#' hx <- list(hello = x)
#' cat(yaml::as.yaml(hx)) # representation in yaml
#' cat(whisker::whisker.render("hello: {{hello}}", hx)) # messed up whisker
#' ```
#'
#' Moreover, we want to indicate that a yaml list is not a single key/value pair
#' so we want to enforce that we have
#'
#' ```
#' key:
#' - value1
#' ```
#'
#' and not
#'
#' ```
#' key: value1
#' ```
#'
#' This converts the elements to a yaml list before it enters whisker and makes
#' sure that the values are clearly lists.
#'
#' ```{r}
#' hx[["hello"]] <- sandpaper:::yaml_list(hx[["hello"]])
#' cat(whisker::whisker.render("hello: {{hello}}", hx)) # good whisker
#' ```
#'
#' @keywords internal
#' @note there IS a better solution than this hack, but for now, we will
#' keep what we are doing because it's okay for our purposes:
#'   https://github.com/rstudio/blogdown/issues/560
#' @examples
#' x <- c("a", "b", "c")
#' hx <- list(hello = x)
#' cat(yaml::as.yaml(hx)) # representation in yaml
#' cat(whisker::whisker.render("hello: {{hello}}", hx)) # messed up whisker
#' hx[["hello"]] <- sandpaper:::yaml_list(hx[["hello"]])
#' cat(whisker::whisker.render("hello: {{hello}}", hx)) # good whisker
yaml_list <- function(thing) {
  # If the yaml item is empty, then return a blank line.
  if (length(thing) == 0) return("")
  # If a thing is not a list, then make it a list
  thing <- if (length(thing) == 1L && !is.list(thing)) list(thing) else thing
  # If it's named, there's no need to create padding.
  pad <- if (is.list(thing) && length(names(thing)) == 1L) "" else "\n"
  paste0(pad, trimws(yaml::as.yaml(thing)))
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
  structure(yaml::yaml.load(yaml, eval.expr = FALSE),
    header = get_information_header(yaml))
}

create_pkgdown_yaml <- function(path) {
  # The user does not interact with this and {{mustache}} is logic-less, so we
  # can be super-verbose here and create any logic we need on the R-side.
  usr <- yaml::read_yaml(path_config(path), eval.expr = FALSE)
  handout <- if (is.null(usr$handout)) "~" else siQuote(usr$handout)
  handout <- if (isTRUE(handout)) "files/code-handout.R" else handout
  yaml <- get_yaml_text(template_pkgdown())
  # Should we display DOI info? If so, parse the URL and return the doi
  # note that a missing doi will return nothing
  doi <- sub("^[/]", "", xml2::url_parse(usr$doi)$path)
  doi <- if (length(doi) == 1L && nzchar(doi)) siQuote(doi) else "~"
  yaml <- whisker::whisker.render(yaml,
    data = list(
      # Basic information
      version = siQuote(utils::packageVersion("sandpaper")),
      config  = siQuote(path_config(path)),
      title   = siQuote(usr$title),
      time    = UTC_timestamp(Sys.time()),
      source  = siQuote(sub("/$", "", usr$source)),
      branch  = siQuote(usr$branch),
      contact = siQuote(usr$contact),
      # What carpentry are we dealing with?
      carpentry_name = siQuote(which_carpentry(usr$carpentry)),
      carpentry      = siQuote(usr$carpentry),
      carpentry_icon = siQuote(which_icon_carpentry(usr$carpentry)),
      license        = siQuote(usr$license),
      handout        = handout,
      cp             = usr$carpentry == 'cp',
      lc             = usr$carpentry == 'lc',
      dc             = usr$carpentry == 'dc',
      swc            = usr$carpentry == 'swc',
      # Should we display a lifecycle banner?
      life_cycle = siQuote(usr$life_cycle),
      pre_alpha  = usr$life_cycle == "pre-alpha",
      alpha      = usr$life_cycle == "alpha",
      beta       = usr$life_cycle == "beta",
      stable     = usr$life_cycle == "stable",
      doi        = doi,
      NULL
    )
  )
  rendered <- yaml::yaml.load(yaml, eval.expr = FALSE)
  items <- names(rendered$template$params)
  rendered$template$params <- c(rendered$template$params,
    c(usr[!names(usr) %in% items]))
  structure(rendered, header = get_information_header(yaml))
}

update_site_timestamp <- function(path) {
  yaml <- get_path_site_yaml(path)
  yaml$template$params$time <- Sys.time()
  write_pkgdown_yaml(yaml, path)
}

get_navbar_info <- function(i) {
  txt <- yaml::yaml.load(politely_get_yaml(i), eval.expr = FALSE)$title
  list(
    pagetitle = txt,
    text  = txt,
    href  = as_html(i)
  )
}

known_yaml_keys <- c(
  "title",
  "carpentry",
  "life_cycle",
  "license",
  "source",
  "branch",
  "contact",
  "created",
  "keywords"
)

known_yaml_items <- c(
  known_yaml_keys,
  "episodes",
  "instructors",
  "learners",
  "profiles"
)


quote_config_items <- function(yaml) {
  for (i in known_yaml_keys) {
    yaml[[i]] <- siQuote(yaml[[i]])
  }
  yaml
}
