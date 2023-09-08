
setup_child_test <- function(lsn_path) {
  # we will copy over an episode "child-haver.Rmd", that will have a child
  # called "files/figures.md"
  parent <- fs::path(lsn_path, "episodes", "child-haver.Rmd")
  child  <- fs::path(lsn_path, "episodes", "files", "figures.md")

  fs::file_copy(test_path("examples", "child-haver.Rmd"), parent)
  fs::file_copy(test_path("examples", "figures.md"), child)
  move_episode("child-haver.Rmd", 2, path = lsn_path, write = TRUE)

  # return the paths we created so we can delete them.
  return(c(parent, child))
}
