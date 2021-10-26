mask_tmpdir <- function(txt, dir) {
  txt <- gsub(dir, "[redacted]", txt, fixed = TRUE)
  gsub("/private[redacted]", "[redacted]", txt, fixed = TRUE)
}
