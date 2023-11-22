# Generate temporary lesson and set `lang: ja` in config.yaml
tmp <- res <- restore_fixture()
config_path <- fs::path(tmp, "config.yaml")
config <- yaml::read_yaml(config_path)
config$lang <- "ja"
yaml::write_yaml(config, config_path)
metadata_json <- trimws(create_metadata_jsonld(tmp))
sitepath <- fs::path(tmp, "site", "docs")

test_that("Lessons can be translated with lang setting", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # Build lesson
  suppressMessages(build_lesson(tmp, preview = FALSE, quiet = FALSE))

  # Extract first header (Summary and Setup) from index
  index <- readLines(fs::path(sitepath, "index.html"))
  xml <- xml2::read_html(paste(index, collapse = ""))
  h1_header <- xml2::xml_find_all(xml, "//h1[@class='schedule-heading']")

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

})
