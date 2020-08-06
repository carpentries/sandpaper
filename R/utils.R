# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

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

# Creates a gitignore file from the template in inst
create_gitignore <- function(path) {
  fs::file_copy(
    system.file("gitignore.txt", package = "sandpaper"), 
    new_path = fs::path(path, ".gitignore")
  )
}
