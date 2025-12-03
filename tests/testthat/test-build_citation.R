test_that("parse_authors returns 'Unknown Author' for NULL or empty", {
  expect_equal(parse_authors(NULL), "Unknown Author")
  expect_equal(parse_authors(list()), "Unknown Author")
})

test_that("parse_authors returns correct HTML for multiple authors and affiliations", {
  authors <- list(
    list("given-names" = "Jane", "family-names" = "Doe", "orcid" = "https://orcid.org/0000-0001-2345-6789"),
    list("given-names" = "Doc", "family-names" = "Brown", "affiliation" = "University A", "orcid" = "https://orcid.org/0000-0009-8765-4321"),
    list("given-names" = "John", "family-names" = "Smith", "affiliation" = "University B")
  )
  env <- parse_authors(authors)
  expect_type(env, "environment")
  expect_match(env$html_authors[1], "Jane Doe<span class='author-info'> <a href='https://orcid.org/0000-0001-2345-6789' target='_blank'><sup><img src='assets/images/orcid_icon.png' height='12' width='12'/></sup></a></span>")
  expect_match(env$html_authors[2], "Doc Brown<span class='author-info'> <a href='#aff1'><sup>1</sup></a>  <a href='https://orcid.org/0000-0009-8765-4321' target='_blank'><sup><img src='assets/images/orcid_icon.png' height='12' width='12'/></sup></a></span>")
  expect_match(env$html_authors[3], "John Smith<span class='author-info'> <a href='#aff2'><sup>2</sup></a>")
  expect_match(paste(env$pre_authors, collapse=", "), "Doe J., Brown D., Smith J.", fixed = TRUE)
  expect_match(env$affiliations, "<p style='font-size=0.8em'>Affiliations:<br/><ol class='affiliations'><li id='aff1'>University A</li><li id='aff2'>University B</li></ol></p>")
})

test_that("read_cff returns NULL for missing file", {
  skip_if_not_installed("cffr")
  expect_null(suppressMessages(read_cff(withr::local_tempfile(fileext = ".cff"))))
})

test_that("read_cff returns error for malformed CFF file", {
  skip_if_not_installed("cffr")
  tmp_cff <- withr::local_tempfile(fileext = ".cff")
  writeLines("invalid cff content", tmp_cff)
  # check that a warning is issued for invalid CFF
  expect_message(
    read_cff(tmp_cff),
    "Error reading CITATION.cff file: 'object' must be a list or expression"
  )
})

test_that("read_cff outputs error when field missing from CFF file", {
  skip_if_not_installed("cffr")
  tmp_cff <- withr::local_tempfile(fileext = ".cff")
  writeLines(c(
    "cff-version: 1.2.0",
    "title: Test Lesson",
    "authors:",
    "  - family-names: Doe",
    "    given-names: Jane"
  ), tmp_cff)
  expect_message(
    read_cff(tmp_cff),
    "cff.message: is required"
  )
})

test_that("read_cff returns list for valid CFF file", {
  skip_if_not_installed("cffr")
  tmp_cff <- withr::local_tempfile(fileext = ".cff")
  writeLines(c(
    "cff-version: 1.2.0",
    "title: Test Lesson",
    "message: Please cite this curriculum using the information below.",
    "authors:",
    "  - family-names: Doe",
    "    given-names: Jane"
  ), tmp_cff)
  result <- suppressMessages(read_cff(tmp_cff))
  expect_type(result$authors, "list")
  expect_equal(result$title, "Test Lesson")
})
