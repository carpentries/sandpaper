# This helper allows me to properly check the output of knitr without running
# afoul of the weird escapes it has
processing_ <- function (file) {
  sprintf("processing file: .+?%s", sub("\\.", "\\\\.", basename(file)))
}
