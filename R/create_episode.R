create_episode <- function(title, make_prefix = TRUE, path = ".") {

  check_lesson()
  episodes <- fs::dir_ls(fs::path(path, "episodes"))
  prefix <- as.integer(sub("^([0-9]{2}).+$", "\\1", episodes))
  prefix <- if (length(prefix) == 0) "01" else sprintf("%02d", max(prefix) + 1L)
  
}
