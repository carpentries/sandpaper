# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

`%nin%` <- Negate("%in%")

as_html <- function(i) fs::path_ext_set(fs::path_file(i), "html")

# Parse a markdown title to html
#
# Note that commonmark wraps the content in <p> tags, so the substring gets rid
# of those:
# <p>Title</p>\n
parse_title <- function(title) {
  title <- commonmark::markdown_html(title)
  substring(title, 4, nchar(title) - 5)
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

  writeLines(glue::glue("# {name}
      
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
  the_author <- paste(gert::git_signature_default(path), "[aut, cre]")
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

which_carpentry <- function(carpentry) {
  switch(carpentry,
    lc = "Library Carpentry",
    dc = "Data Carpentry",
    swc = "Software Carpentry",
    cp = "The Carpentries",
    incubator = "Carpentries Incubator",
    lab = "Carpentries Lab"
  )
}

varnish_vars <- function() {
  ver <- function(pak) glue::glue(" ({packageVersion(pak)})")
  list(
    sandpaper_version = ver("sandpaper"),
    pegboard_version  = ver("pegboard"),
    varnish_version   = ver("varnish")
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
  ours[!grepl("^([#].+?|)$", trimws(ours))]
}
#nocov end

