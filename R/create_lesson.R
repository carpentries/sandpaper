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
  fs::dir_create(fs::path(path, "episodes", "figures"))
  fs::dir_create(fs::path(path, "episodes", "extras"))

  fs::dir_create(fs::path(path, "site"))
  fs::dir_create(fs::path(path, "site", "vignettes"))

  fs::file_create(fs::path(path, "site", "DESCRIPTION"))
  fs::file_create(fs::path(path, "README.md"))
  fs::file_create(fs::path(path, "site", "README.md"))
  copy_template("gitignore", path, ".gitignore")
  copy_template("config", path, "config.yml")

  writeLines(glue::glue("# {name}
      
      This is the lesson repository for {name}
  "), con = fs::path(path, "README.md"))

  writeLines(glue::glue("
  This directory contains rendered lesson materials. Please do not edit files
  here.  
  "), con = fs::path(path, "site", "README.md"))
  
 
  create_episode("introduction", path = path)
  create_description(path)
  create_pkgdown_yaml(path)
  gert::git_add(".", repo = path)
  gert::git_commit(message = "Initial commit [via {sandpaper}]", repo = path)
  reset_git_user(path)
  
  return(path)
  

}

