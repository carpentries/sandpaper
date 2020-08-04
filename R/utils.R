# Null operator
`%||%` <- function(a, b) if (is.null(a)) b else a

dir_available <- function(path) {
  !fs::dir_exists(path) || nrow(fs::dir_info(path)) == 0L
}
