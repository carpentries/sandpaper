# utility for checking if a file has the expected hash
#
# @param path the path to the lesson
# @param file the path to the episode to be hashed (in the episodes dir)
expect_hashed <- function(path, file) {
  expected_hash <- tools::md5sum(fs::path(path_episodes(path), file))
  md <- fs::path_ext_set(file, "md")
  actual_hash <- get_hash(fs::path(path_built(path), md))
  expect_equal(actual_hash, expected_hash, ignore_attr = TRUE)
}
