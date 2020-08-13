# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

`%nin%` <- Negate("%in%")

dir_available <- function(path) {
  !fs::dir_exists(path) || nrow(fs::dir_info(path)) == 0L
}


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

create_pkgdown_yaml <- function(path) {
  cat(
    yaml::as.yaml(list(template = list(package = "varnish"))),
    file = fs::path(path_site(path), "_pkgdown.yml")
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
      message(header)
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

root_path <- function(path) rprojroot::find_root(rprojroot::is_git_root, path)

make_here <- function(ROOT) {
  force(ROOT)
  function(leaf = "") fs::path(ROOT, leaf)
}

path_site <- function(path) {
  home <- root_path(path)
  fs::path(home, "site")
}
path_pkgdown <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "site", "vignettes")
}

path_episodes <- function(inpath) {
  home <- root_path(inpath)
  fs::path(home, "episodes")
}

get_source_files <- function(path) {
  fs::dir_ls(path_episodes(path), regexp = "*R?md")
}

get_built_files <- function(path) {
  fs::dir_ls(path_pkgdown(path), glob = "*Rmd")
}

get_episode_slug <- function(path) {
  fs::path_ext_remove(fs::path_file(path))
}

get_artifact_files <- function(path) {
  fs::dir_ls(path_episodes(path), 
    regexp = "*R?md", 
    invert = TRUE, 
    type = "file", 
    all = TRUE
  )
}
