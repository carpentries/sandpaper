#' Create a carpentries lesson
#'
#' This will create a boilerplate directory structure for a Carpentries lesson
#' and initialize a git repository.
#'
#' @param path the path to the new lesson folder
#' @param name the name of the lesson. If not provided, the folder name will be used.
#' @param rstudio create an RStudio project (defaults to if RStudio exits)
#' @param open if interactive, the lesson will open in a new editor window.
#'
#' @export
#' @return the path to the new lesson
#' @examples
#' tmp <- tempfile()
#' on.exit(unlink(tmp))
#' lsn <- create_lesson(tmp, name = "This Lesson")
#' lsn
create_lesson <- function(path, name = fs::path_file(path), rstudio = rstudioapi::isAvailable(), open = rlang::is_interactive()) {

  if (!dir_available(path)) {
    stop(glue::glue("{path} is not an empty directory."))
  }

  gert::git_init(path)
  check_git_user(path)

  fs::dir_create(fs::path(path, "episodes"))
  fs::dir_create(fs::path(path, "episodes", "data"))
  fs::dir_create(fs::path(path, "episodes", "files"))
  fs::dir_create(fs::path(path, "episodes", "fig"))
  fs::dir_create(fs::path(path, "episodes", "extras"))
  fs::file_create(fs::path(path, "README.md"))

  copy_template("gitignore", path, ".gitignore")
  copy_template("config", path, "config.yml")

  create_lesson_readme(name, path)
  create_site(path)

  create_episode("introduction", path = path)
  update_schedule(path)

  gert::git_add(".", repo = path)
  gert::git_commit(message = "Initial commit [via {sandpaper}]", repo = path)
  reset_git_user(path)
  
  return(path)

}

