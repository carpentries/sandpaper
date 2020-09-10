# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

`%nin%` <- Negate("%in%")

as_html <- function(i) fs::path_ext_set(fs::path_file(i), "html")

UTC_timestamp <- function(x) format(x, "%F %T %z", tz = "UTC")

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

create_lesson_readme <- function(name, path) {

  writeLines(glue::glue("# {name}
      
      This is the lesson repository for {name}
  "), con = fs::path(path, "README.md"))

}

create_site_readme <- function(path) {
  readme <- fs::path(path, "site", "README.md")
  if (!fs::file_exists(readme)) {
    fs::file_create(readme)
  }
  writeLines(glue::glue("
  This directory contains rendered lesson materials. Please do not edit files
  here.  
  "), con = readme)
}

create_description <- function(path) {
  yaml <- yaml::read_yaml(path_config(path))
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
  )
}

create_pkgdown_yaml <- function(path) {
  # The user does not interact with this and {{mustache}} is logic-less, so we
  # can be super-verbose here and create any logic we need on the R-side.
  usr <- yaml::read_yaml(path_config(path))
  yaml <- get_yaml_text(template_pkgdown())
  yaml <- whisker::whisker.render(yaml, 
    data = list(
      # Basic information
      version = utils::packageVersion("sandpaper"),
      config  = path_config(path),
      title   = usr$title,
      time    = UTC_timestamp(Sys.time()),
      source  = usr$source,
      branch  = usr$branch,
      contact = usr$contact,
      # What carpentry are we dealing with?
      carpentry_name = which_carpentry(usr$carpentry),
      carpentry      = usr$carpentry,
      cp             = usr$carpentry == 'cp',
      lc             = usr$carpentry == 'lc',
      dc             = usr$carpentry == 'dc',
      swc            = usr$carpentry == 'swc',
      # Should we display a lifecycle banner?
      life_cycle = if (usr$life_cycle == "stable")    "~"  else usr$life_cycle,
      pre_alpha  = if (usr$life_cycle == "pre-alpha") TRUE else "~",
      alpha      = if (usr$life_cycle == "alpha")     TRUE else "~",
      beta       = if (usr$life_cycle == "beta")      TRUE else "~",
      NULL     
    )
  )
  structure(yaml::yaml.load(yaml), header = get_information_header(yaml))
}

update_site_timestamp <- function(path) {
  yaml <- get_path_site_yaml(path) 
  yaml$template$params$time <- Sys.time()
  write_pkgdown_yaml(yaml, path)
}

update_site_menu <- function(path, episodes) {
  yaml <- get_path_site_yaml(path)
  res <- lapply(episodes, function(i) {
    txt <- yaml::yaml.load(politely_get_yaml(i))$title
    list(
      pagetitle = txt,
      text  = txt,
      href  = as_html(i)
    )
  })
  yaml$navbar$left[[1]]$menu <- unname(res)
  write_pkgdown_yaml(yaml, path)
}

get_hash <- function(path) {
  yaml <- politely_get_yaml(path)
  sub("sandpaper-digest: ", "", grep("sandpaper-digest: ", yaml, value = TRUE))
}

copy_assets <- function(src, dst) {
  dst <- fs::path(dst, fs::path_file(src))
  if (fs::is_dir(src)) {
    fs::dir_copy(src, dst, overwrite = TRUE)
  } else if (fs::is_file(src)) {
    fs::file_copy(src, dst, overwrite = TRUE)
  } else {
    stop(paste(src, "does not exist"), call. = FALSE)
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
