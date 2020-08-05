check_lesson <- function(path = ".") {
  x <- fs::dir_info(path, all = TRUE) 
  files <- fs::basename(x$path)
  check_dir <- function(path, i) {
    assertthat::see_if(assertthat::is.dir(fs::path(path, i)))
  }

  episodes <- check_dir(path, "episodes")
  site <- check_dir(path, "site")
  git <- check_dir(path, ".git")


}
