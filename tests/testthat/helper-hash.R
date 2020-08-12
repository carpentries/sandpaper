expect_hashed <- function(path, file) {
  expected_hash <- tools::md5sum(fs::path(path, "episodes", file))
  actual_hash   <- get_hash(fs::path(path, "site", "vignettes", file))
  expect_equivalent(expected_hash, actual_hash)
}
