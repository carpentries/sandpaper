# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

`%nin%` <- Negate("%in%")

# Functions for backwards compatibility for R < 3.5
isFALSE <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && !x
isTRUE  <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && x

# If the git user is not set, we set a temporary one, note that this is paired
# with reset_git_user()
check_git_user <- function(path) {
  if (!gert::user_is_configured(path)) {
    gert::git_config_set("user.name", "carpenter", repo = path)
    gert::git_config_set("user.email", "team@carpentries.org", repo = path)
  }
}

# This checks if we have set a temporary git user and then unsets it. It will 
# supriously unset a user if they happened to have 
# "carpenter <team@carpentries.org>" as their email.
reset_git_user <- function(path) {
  cfg <- gert::git_config(path)
  it_me <- cfg$value[cfg$name == "user.name"] == "carpenter" &&
    cfg$value[cfg$name == "user.email"] == "team@carpentries.org"
  if (gert::user_is_configured(path) && it_me) {
    gert::git_config_set("user.name", NULL, repo = path)
    gert::git_config_set("user.email", NULL, repo = path)
  }
}

#nocov start
# Make it easy to contribute to our gitignore template, but also avoid having
# to reload this thing every time we need it 
gitignore_items <- function() {
  ours <- readLines(template_gitignore(), encoding = "UTF-8")
  ours[!grepl("^([#].+?|)$", trimws(ours))]
}

.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)
  delayedAssign("GITIGNORED", gitignore_items(), eval.env = ns, assign.env = ns)
}
#nocov end

create_lesson_readme <- function(name, path) {

  writeLines(glue::glue("# {name}
      
      This is the lesson repository for {name}
  "), con = fs::path(path, "README.md"))

}

create_site_readme <- function(path) {
  writeLines(glue::glue("
  This directory contains rendered lesson materials. Please do not edit files
  here.  
  "), con = fs::path(path, "site", "README.md"))
}

create_description <- function(path) {
  the_author <- paste(gert::git_signature_default(path), "[aut, cre]")
  the_author <- utils::as.person(the_author)
  author_string <- format(the_author, style = "R")
  desc <- desc::desc(text = 
    paste0(
      "Package: lesson\n",
      "Authors@R:", paste(author_string, collapse = "\n"), "\n",
      "Version: 0.1.0\n",
      "Description: Lesson Template (not a real package)]\n",
      "License: CC-0\n",
      "Encoding: UTF-8\n"
    )
  )
  writeLines(desc$str(by_field = TRUE, normalize = FALSE, mode = "file"),
    fs::path(path_site(path), "DESCRIPTION")
  )
}

timestamp <- function(x) format(x, "%F %T %z", tz = "UTC")

which_carpentry <- function(carpentry) {
  switch(carpentry,
    lc = "Library Carpentry",
    dc = "Data Carpentry",
    swc = "Software Carpentry",
    cp = "The Carpentries",
  )
}

create_pkgdown_yaml <- function(path) {
  usr <- yaml::read_yaml(fs::path(path, "config.yml"))
  usr$life_cycle <- "pre-alpha"
  config <- list(
    title = usr$title,
    template = list(
      package = "varnish",
      params = list(
        time = Sys.time(),
        cslug = usr$carpentry,
        carpentry = which_carpentry(usr$carpentry),
        life_cycle = if (usr$life_cycle == "stable") NULL else usr$life_cycle,
        pre_alpha = if (usr$life_cycle == "pre-alpha") TRUE else NULL,
        alpha = if (usr$life_cycle == "alpha") TRUE else NULL,
        beta = if (usr$life_cycle == "beta") TRUE else NULL
      )
    )
  )
  out <- fs::path(path_site(path), "_pkgdown.yml")
  yaml::write_yaml(
    config, 
    file = out,
    handlers = list(POSIXct = timestamp)
  )
}

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

get_hash <- function(path) {
  yml <- politely_get_yaml(path)
  sub("sandpaper-digest: ", "", grep("sandpaper-digest: ", yml, value = TRUE))
}

