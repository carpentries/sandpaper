expect_hashed <- function(path, file) {
  expected_hash <- tools::md5sum(fs::path(path_episodes(path), file))
  md <- fs::path_ext_set(file, "md")
  actual_hash   <- get_hash(fs::path(path_built(path), md))
  expect_equal(expected_hash, actual_hash, ignore_attr = TRUE)
}
