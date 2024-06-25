# Null operator
`%||%` <- function(a, b) if (length(a) < 1L) b else a

`%nin%` <- Negate("%in%")

as_html <- function(i, instructor = FALSE) {
  if (length(i) == 0) return(i)
  res <- fs::path_ext_set(fs::path_file(i), "html")
  if (instructor) fs::path("instructor", res) else res
}

example_can_run <- function(need_git = FALSE, skip_cran = TRUE) {
  no_need_git <- !need_git
  run_ok <- (no_need_git || has_git()) &&
   requireNamespace("withr", quietly = TRUE) &&
   rmarkdown::pandoc_available("2.11")
  if (skip_cran) {
    run_ok <- run_ok && identical(Sys.getenv("NOT_CRAN"), "true")
  }
  run_ok
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

# Search parent calls for a specific set of function signatures and return TRUE
# if any one of them match.
parent_calls_contain <- function(search = NULL, calls = sys.calls()) {
  # escape early if there is no search. No search; no match.
  if (length(search) == 0L || is.na(search)[[1L]]) {
    return(FALSE)
  }
  # we assume no match
  found <- FALSE
  # calls will be arranged in order from user -> here, so the first call will
  # be the call that triggered the chain of command.
  for (call in calls) {
    # the first part of the call will be the function name
    if (!inherits(call[[1]], "name")) {
      # but sometimes it will be an anyonymous function, such as the
      # onWSMessage function from httpuv:
      # https://github.com/rstudio/httpuv/blob/faada3a19965af80289919308587836d22198a24/R/httpuv.R#L285-L293
      # in these cases, we must skip
      next
    }
    fn <- as.character(call[[1L]])
    # pkg::function is parsed as the character c("::", "pkg", "function")
    # because "::" is a function, thus if we have 3, we take the function name
    if (length(fn) == 3L) {
      fn <- fn[3L]
    } else {
      fn <- fn[1L]
    }
    found <- fn %in% search || found
    # once we find it, return early. This limits the time we spend in this loop
    if (found) {
      return(found)
    }
  }
  # if we reach here, it should be FALSE.
  found
}

in_production <- function(calls = sys.calls()) {
  fns <- c("ci_deploy", "ci_build_site", "ci_build_markdown")
  parent_calls_contain(fns, calls)
}


# Parse a markdown title to html
#
# Note that commonmark wraps the content in <p> tags, so the substring gets rid
# of those:
# <p>Title</p>\n
parse_title <- function(title) {
  title <- commonmark::markdown_html(title)
  substring(title, 4, nchar(title) - 5)
}

make_github_url <- function(path) {
  res <- strsplit(path, "/")[[1]][-(1:3)]
  paste0("https://", res[1], ".github.io/", res[2])
}


slugify <- function(title) {
  # remove emoji encoded as github codes (e.g. :joy_cat:)
  slug <- gsub("(?>\\s|^)[:][a-z_]+?[:](?=\\s|$)", "-", tolower(title), perl = TRUE)
  # replace all punctuation and spaces with a single hyphen, but preserve
  # emojis and non latin characters
  slug <- gsub("[[:punct:][:space:]]+", "-", slug, perl = TRUE)
  # trim hanging hyphens
  gsub("^[-]|[-]$", "", slug, perl = TRUE)
}


set_common_links <- function(path = ".") {
  links <- getOption("sandpaper.links")
  # Include common links if they exist ----------------------------------------
  home <- tryCatch(root_path(path), error = function(e) character(0))
  if (length(home) && length(links) == 0L) {
    links <- fs::path(home, "links.md")
  }
  options("sandpaper.links" = links)
  links
}



get_trimmed_title <- function(next_page) {
  next_page <- get_navbar_info(next_page)
  if (is.null(next_page$pagetitle)) {
    return(NULL)
  }
  next_title <- strsplit(next_page$pagetitle, "\\s")[[1]]
  # only allow titles up to 20 characters long
  ok <- (cumsum(nchar(next_title)) + (seq(next_title) - 1)) <= 20
  if (sum(ok) > 0) {
    parse_title(paste(next_title[ok], collapse = " "))
  } else {
    parse_title(substr(next_page$pagetitle, 1, 20))
  }
}

copy_maybe <- function(path, new_path) {
  if (fs::file_exists(path)) {
    fs::file_copy(path, new_path, overwrite = TRUE)
  }
}

copy_lockfile <- function(sources, new_path) {
  lock <- fs::path_file(sources) == "renv.lock"
  this_lock <- sources[lock]
  this_lock <- this_lock[length(this_lock)]
  if (any(lock) && fs::file_exists(this_lock)) {
    fs::file_copy(this_lock, new_path, overwrite = TRUE)
  }
}

UTC_timestamp <- function(x) format(x, "%F %T %z", tz = "UTC")

# Functions for backwards compatibility for R < 3.5
isFALSE <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && !x
isTRUE  <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && x

create_lesson_readme <- function(name, path) {

  writeLines(glue::glue("## {name}

      This is the lesson repository for {name}
  "), con = fs::path(path, "README.md"))

}

create_site_readme <- function(path) {
  readme <- fs::path(path_site(path), "README.md")
  if (!fs::file_exists(readme)) {
    fs::file_create(readme)
  }
  writeLines(glue::glue("
  This directory contains rendered lesson materials. Please do not edit files
  here.
  "), con = readme)
}

create_description <- function(path) {
  yaml <- yaml::read_yaml(path_config(path), eval.expr = FALSE)
  the_author <- paste("Jo Carpenter <team@carpentries.org> [aut, cre]")
  the_author <- utils::as.person(the_author)
  desc <- desc::description$new("!new")
  desc$del(c("BugReports", "LazyData"))
  desc$set_authors(the_author)
  desc$set(
    Package     = "lesson",
    Title       = yaml$title,
    Description = "Lesson Template (not a real package).",
    License     = yaml$license,
    Encoding    = "UTF-8"
  )
  desc$write(fs::path(path_site(path), "DESCRIPTION"))
}

which_carpentry <- function(carpentry, carpentry_description = NULL) {
  if (!is.null(carpentry_description)) {
    return(carpentry_description)
  }
  switch(carpentry,
    lc = "Library Carpentry",
    dc = "Data Carpentry",
    swc = "Software Carpentry",
    cp = "The Carpentries",
    incubator = "Carpentries Incubator",
    lab = "Carpentries Lab",
    # Default: match the input
    carpentry
  )
}

which_icon_carpentry <- function(carpentry) {
  switch(carpentry,
    lc = "library",
    dc = "data",
    swc = "software",
    cp = "carpentries",
    incubator = "incubator",
    lab = "lab",
    # Default: match the input
    carpentry
  )
}

copy_assets <- function(src, dst) {
  # Do not take markdown files.
  if (fs::path_ext(src) == "md") return(invisible(NULL))

  # FIXME: modify this to allow for non-flat file structure
  dst <- fs::path(dst, fs::path_file(src))

  # Copy either directories or files.
  if (fs::is_dir(src) && fs::path_file(src) != ".git") {
    tryCatch(fs::dir_copy(src, dst, overwrite = TRUE), error = function (e) {
      rel <- fs::path_common(c(src, dst))
      pth <- fs::path_rel(src, rel)
      cli::cli_alert_warning("There was an issue copying {.file {pth}}:\n{e$message}")
    })
  } else if (fs::is_file(src) && fs::path_file(src) != ".git") {
    fs::file_copy(src, dst, overwrite = TRUE)
  } else if (fs::path_file(src) == ".git") {
    # skipping git
  } else {
    stop(paste(src, "does not exist"), call. = FALSE)
  }
  return(invisible(NULL))
}

get_figs <- function(path, slug) {
  fs::path_abs(
    fs::dir_ls(
      path = fs::path(path_built(path), "fig"),
      regexp = paste0(slug, "-rendered-"),
      fixed = TRUE
    )
  )
}

check_order <- function(order, what) {
  if (is.null(order)) {
    stop(paste(what, "must have an order"), call. = FALSE)
  }
}


#nocov start
# Make it easy to contribute to our gitignore template, but also avoid having
# to reload this thing every time we need it
gitignore_items <- function() {
  ours <- readLines(template_gitignore(), encoding = "UTF-8")
  ours[!grepl("^([#].+?|.+? # OPTIONAL|)$", trimws(ours))]
}
#nocov end

