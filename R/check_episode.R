check_episode <- function(path) {
  episode_name <- fs::path_file(path)
  
  check_dir <- function(path, i) {
    assertthat::see_if(assertthat::is.dir(fs::path(path, i)),
      msg = paste0(i, "/ does not exist")
    )
  }
}
