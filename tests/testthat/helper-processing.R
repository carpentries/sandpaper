# utility for checking the output of knotr
#
# @param object R object to evaluate
# @param file the filename to have things escaped
processing_ <- function (file) {
  sprintf("processing file: .+?%s", sub("\\.", "\\\\.", basename(file)))
}
