# Generate temporary lesson and set `lang: ja` in config.yaml
tmp <- res <- restore_fixture()
config_path <- fs::path(tmp, "config.yaml")
config <- yaml::read_yaml(config_path)
config$lang <- "ja"
yaml::write_yaml(config, config_path)
sitepath <- fs::path(tmp, "site", "docs")

test_that("Lessons can be translated with lang setting", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()

  skip_if(os == "windows" && ver < "4.2")

  # Build lesson
  suppressMessages(build_lesson(tmp, preview = FALSE, quiet = TRUE))

  # Extract first header (Summary and Setup) from index
  xml <- xml2::read_html(fs::path(sitepath, "index.html"))
  h1_header <- xml2::xml_find_all(xml, "//h1[@class='schedule-heading']")

  # language should be set to japanese
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")

  # Header should be translated to Japanese
  expect_true(
    identical(
      xml2::xml_text(h1_header),
      withr::with_language("ja", tr_("Summary and Setup"))
    )
  )

  # Header should no longer be in English
  expect_false(
    identical(
      xml2::xml_text(h1_header),
      withr::with_language("en", tr_("Summary and Setup"))
    )
  )

  # aria labels should be translated
  arias <- c("Main Navigation", "Toggle Navigation", "Search", "search button",
    "Lesson Progress", "close menu", "Next Chapter", "anchor", "Back To Top")
  ja_arias <- withr::with_language("ja", vapply(arias, tr_, character(1)))

  expect_false(identical(arias, ja_arias))

  expect_setequal(
    ja_arias,
    xml2::xml_text(xml2::xml_find_all(xml, ".//@aria-label"))
  )


})
