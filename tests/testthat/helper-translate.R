#' Expect translations are rendered properly in the HTML page
#'
#' One of the challenges of translations is that we need to test both that the
#' translation works and that the default text does not work.
#'
#' We are using the `tr_()` function to ensure that our translations are
#' working, so we expect that we can use the following to test that the
#' translation works:
#'
#' ```
#' expected <- withr::with_language("ja", tr_("Summary and Setup"))
#' expect_equal(xml2::xml_text(node, trim = TRUE), expected)
#' ```
#'
#' This logic is not wrong, but it will almost always give a successful result
#' because if the `tr_()` function does not find a translation, it will return
#' the same string. Thus, we need to pair this with an expectation that we know
#' should fail---translating the default state for English:
#'
#' ```
#' unexpected <- withr::with_language("en", tr_("Summary and Setup"))
#' expect_failure({
#'   expect_equal(xml2::xml_text(node, trim = TRUE), unexpected)
#' })
#' ```
#'
#' It's with this pair of expectations that we can confirm that a translation
#' is working correctly. This function also expands this idea to compare sets of
#' translations when there may be duplicates.
#'
#' @param node an xml_node or xml_nodeset object
#' @param strings a character vector of _untranslated_ strings
#' @param language a character vector of length 1 defining the language to use
#'   for translations
#' @noRd
#' @examples
#' sitepath <- fs::path(lsn, "site/docs")
#' profiles <- xml2::read_html(fs::path(sitepath, "profiles.html"))
#' h1_profiles <- xml2::xml_find_first(profiles, "//main/div/h1")
#' expect_set_translated(h1_profiles, "Learner Profiles")
expect_set_translated <- function(node, strings, language = "ja") {
  # translate a vector into the defined langage and english for comparison
  expected_strings <- withr::with_language(language, {
    unname(vapply(strings, tr_, character(1)))
  })
  en_strings <- withr::with_language("en", {
    unname(vapply(strings, tr_, character(1)))
  })
  actual <- xml2::xml_text(node, trim = TRUE)

  # The translations should work.
  # NOTE: this will work even if the translation function is not working and
  # falls back to English.
  # --- reasons why this would not work:
  # --- 1. the language of the web page is different than the language
  # --- 2. the web page has no text
  # --- 3. the tr_() function returns NA
  expect_setequal(actual, expected = expected_strings)

  # The English should NOT work
  # --- reasons why this would not work:
  # --- 1. the tr_() function is not actually performing any translations
  expect_failure({
    expect_setequal(actual, expected = en_strings)
  })
}



