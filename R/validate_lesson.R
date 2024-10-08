#' Pre-build validation of lesson elements
#'
#' A validator based on the [pegboard::Lesson] class cached with [this_lesson()]
#' that will provide line reports for fenced divs, links, images, and heading
#' structure. For details on the type of validators avaliable, see the 
#' `{pegboard}` article [Validation of Lesson 
#' Elements](https://carpentries.github.io/pegboard/articles/validation.html)
#'
#' @details
#'
#' ## Headings
#'
#' We expect the headings to be semantic and informative. Details of the tests
#' for headings can be found at [pegboard::validate_headings()]
#'
#' ## Internal Links and Images
#'
#' Internal links and images should exist and images should have alt text.
#' Details for these tests can be found at [pegboard::validate_links()]
#'
#' ## Fenced Divs (callout blocks)
#'
#' Callout Blocks should be one of the expected types. Details for this test
#' can be found at [pegboard::validate_divs()]
#'
#' @param path the path to the lesson. Defaults ot the current directory
#' @param headings If `TRUE`, headings will be checked and validated. Currently
#'   set to `FALSE` as we are re-investigating some false positives.
#' @param quiet if `TRUE`, no messages will be issued, otherwise progress
#'   messages will be issued for each test
#' @return a list with the results for each test as described in 
#'    [pegboard::Lesson]
#' @keywords internal
#' @export
#' @examples
#' tmp <- tempfile()
#' lsn <- create_lesson(tmp, open = FALSE)
#' validate_lesson(lsn, headings = TRUE)
validate_lesson <- function(path = ".", headings = FALSE, quiet = FALSE) {
  lesson <- this_lesson(path)
  val_headings <- NULL
  if (headings) {
    if (!quiet) cli::cli_rule("Validating Headings")
    val_headings <- lesson$validate_headings()
  }
  if (!quiet) cli::cli_rule("Validating Fenced Divs")
  val_divs <- lesson$validate_divs()

  if (!quiet) cli::cli_rule("Validating Internal Links and Images")
  val_links <- lesson$validate_links()

  invisible(list(links = val_links, divs = val_divs, headings = val_headings))
}
