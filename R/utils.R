# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

`%nin%` <- Negate("%in%")

# Functions for backwards compatibility for R < 3.5
isFALSE <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && !x
isTRUE  <- function(x) is.logical(x) && length(x) == 1L && !is.na(x) && x
quot <- function(x) paste0("\"", x, "\"")

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

set_knitr_opts <- function() {
  knitr::opts_chunk$set(
    comment = "",
    fig.align = "center",
    class.output = "output",
    class.error = "error",
    class.warning = "warning",
    class.message = "output"
  )
}

set_fig_path <- function(slug) {
  knitr::opts_chunk$set(fig.path = file.path("fig", paste0(slug, "-")))
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
  yml <- yaml::read_yaml(fs::path(path, "config.yml"))
  the_author <- paste(gert::git_signature_default(path), "[aut, cre]")
  the_author <- utils::as.person(the_author)
  desc <- desc::description$new("!new")
  desc$del(c("BugReports", "LazyData"))
  desc$set_authors(the_author)
  desc$set(
    Package     = "lesson",
    Title       = yml$title,
    Description = "Lesson Template (not a real package).",
    License     = yml$license,
    Encoding    = "UTF-8"
  )
  desc$write(fs::path(path_site(path), "DESCRIPTION"))
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

yaml_writer <- function(yml, path) {
  yaml::write_yaml(
    yml, 
    file = path,
    handlers = list(POSIXct = timestamp)
  )
}

write_pkgdown_yaml <- function(yml, path) {
  yaml_writer(yml, path_site_yaml(path))
}

create_pkgdown_yaml <- function(path) {
  usr <- yaml::read_yaml(fs::path(path, "config.yml"))
  life_cycle <- if (usr$life_cycle == "stable")    "~"  else usr$life_cycle
  pre_alpha  <- if (usr$life_cycle == "pre-alpha") TRUE else "~"
  alpha      <- if (usr$life_cycle == "alpha")     TRUE else "~"
  beta       <- if (usr$life_cycle == "beta")      TRUE else "~"
  usr$carpentry <- "swc"
  cname      <- which_carpentry(usr$carpentry)
  yml <- " 
  title: {cname}
  home:
    strip_header: true
    title: {usr$title}
    description: ~
  navbar:
    title: {usr$title}
    type: default
    left:
      - text: Episodes
        menu: ~ # episodes will be populated here
  template:
    package: varnish
    params:
      time: {Sys.time()}
      cp: {usr$carpentry == 'cp'}
      lc: {usr$carpentry == 'lc'}
      dc: {usr$carpentry == 'dc'}
      swc: {usr$carpentry == 'swc'}
      carpentry: {usr$carpentry}
      carpentry_name: {cname}
      life_cycle: {life_cycle}
      pre_alpha: {pre_alpha}
      alpha: {alpha}
      beta: {beta}
  "
  yaml::yaml.load(glue::glue(yml))
}

update_site_timestamp <- function(path) {
  yml <- yaml::read_yaml(path_site_yaml(path)) 
  yml$template$params$time <- Sys.time()
  write_pkgdown_yaml(yml, path)
}

update_site_menu <- function(path, episodes) {
  yml <- yaml::read_yaml(path_site_yaml(path))
  res <- lapply(episodes, function(i) {
    txt <- yaml::yaml.load(politely_get_yaml(i))$title
    list(
      pagetitle = txt,
      text  = txt,
      href  = fs::path_ext_set(fs::path_file(i), "html")
    )
  })
  yml$navbar$left[[1]]$menu <- unname(res)
  write_pkgdown_yaml(yml, path)
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

copy_assets <- function(src, dst) {
  dst <- fs::path(dst, fs::path_file(src))
  if (fs::is_dir(src)) {
    fs::dir_copy(src, dst, overwrite = TRUE)
  } else {
    fs::file_copy(src, dst, overwrite = TRUE)
  }
}

