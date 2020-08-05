# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

dir_available <- function(path) {
  !fs::dir_exists(path) || nrow(fs::dir_info(path)) == 0L
}




check_git_user <- function(path) {
  if (!gert::user_is_configured(path)) {
    gert::git_config_set("user.name", "carpenter", repo = path)
    gert::git_config_set("user.email", "team@carpentries.org", repo = path)
  }
}

reset_git_user <- function(path) {
  cfg <- gert::git_config(path)
  it_me <- cfg$value[cfg$name == "user.name"] == "carpenter" &&
    cfg$value[cfg$name == "user.email"] == "team@carpentries.org"
  if (gert::user_is_configured(path) && it_me) {
    gert::git_config_set("user.name", NULL, repo = path)
    gert::git_config_set("user.email", NULL, repo = path)
  }
}

create_gitignore <- function(path) {
  fs::file_copy(
    system.file("gitignore.txt", package = "sandpaper"), 
    new_path = fs::path(path, ".gitignore")
  )
}
