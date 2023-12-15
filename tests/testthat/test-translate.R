# Generate temporary lesson and set `lang: ja` in config.yaml
tmp <- res <- restore_fixture()
config_path <- fs::path(tmp, "config.yaml")
config <- yaml::read_yaml(config_path)
config$lang <- "ja"
yaml::write_yaml(config, config_path)
sitepath <- fs::path(tmp, "site", "docs")

test_that("set_language() uses english by default", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  # default is english
  set_language()
  expect_equal(tr_("OUTPUT"), "OUTPUT")

  # set to japanese and it becomes different
  set_language("ja")
  OUTJA <- tr_("OUTPUT")
  expect_false(identical(OUTJA, "OUTPUT"))

  # unknown language will not switch the current language
  suppressMessages(expect_message(set_language("xx"), "languages"))
  expect_equal(tr_("OUTPUT"), OUTJA)

  # set back to english (default)
  set_language()
  expect_equal(tr_("OUTPUT"), "OUTPUT")

})


test_that("set_language() can use country codes", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  expect_silent(set_language("es_AR"))
  OUTAR <- tr_("OUTPUT")
  expect_false(identical(OUTAR, "OUTPUT"))

  # the country codes will fall back to language code if they don't exist
  expect_silent(set_language("es"))
  expect_equal(tr_("OUTPUT"), OUTAR)

})


test_that("is_known_language returns a warning for an unknown language", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  expect_true(is_known_language("ja"))
  expect_false(is_known_language("xx"))
  suppressMessages({
    expect_message({
      expect_false(is_known_language("xx", warn = TRUE))
    }, "languages", label = "is_known_language(warn = TRUE)")
  })

})


test_that("Lessons can be translated with lang setting", {

  # NOTE: this requires the expect_set_translated() function defined in
  # tests/testthat/helper-translate.R 

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  # Build lesson
  suppressMessages(build_lesson(tmp, preview = FALSE, quiet = TRUE))

  # Home Page ------------------------------------------------------
  xml <- xml2::read_html(fs::path(sitepath, "index.html"))
  # language should be set to japanese
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")

  # Extract first header (Summary and Setup) from index
  h1_header <- xml2::xml_find_all(xml, "//h1[@class='schedule-heading']")
  expect_set_translated(h1_header, "Summary and Setup")

  # Navbar has expected text
  nav_links <- xml2::xml_find_all(xml, "//a[starts-with(@class,'nav-link')]")
  expect_set_translated(nav_links,
    c("Key Points", "Glossary", "Learner Profiles")
  )

  # aria labels should be translated
  aria_text <- c(
    "Main Navigation",
    "Toggle Navigation",
    "Search",
    "search button",
    "Lesson Progress",
    "close menu",
    "Next Chapter",
    "anchor",
    "Back To Top"
  )
  aria_labels <- xml2::xml_find_all(xml, ".//@aria-label")
  expect_set_translated(aria_labels, aria_text)


  # GENERATED PAGES ------------------------------------------------
  # Check generated page headers
  inst_note <- xml2::read_html(fs::path(sitepath, "instructor/instructor-notes.html"))
  h1_inst <- xml2::xml_find_first(inst_note, "//main/div/h1")
  expect_set_translated(h1_inst, "Instructor Notes")

  profiles <- xml2::read_html(fs::path(sitepath, "profiles.html"))
  h1_profiles <- xml2::xml_find_first(profiles, "//main/div/h1")
  expect_set_translated(h1_profiles, "Learner Profiles")


  # Episode elements -------------------------------------------------
  # We use here the Instructor view because it is more fully featured
  xml <- xml2::read_html(fs::path(sitepath, "instructor", "introduction.html"))
  nav_links <- xml2::xml_find_all(xml, "//a[starts-with(@class,'nav-link')]")

  # navbar has expected text
  expect_set_translated(nav_links,
    c("Key Points", "Instructor Notes", "Extract All Images")
  )

  # aria labels should be translated
  aria_text <- c(
    "Main Navigation",
    "Toggle Navigation",
    "Search",
    "search button",
    "Lesson Progress",
    "close menu",
    "Previous and Next Chapter", 
    "anchor",
    "Back To Top"
  )
  aria_labels <- xml2::xml_find_all(xml, ".//@aria-label")
  expect_set_translated(aria_labels, aria_text)

  # overview, objectives, and questions
  overview_card <- xml2::xml_find_first(xml, ".//div[@class='overview card']")
  over_heads <- xml2::xml_find_all(overview_card, ".//h2 | .//h3")
  expect_set_translated(over_heads, c("Overview", "Questions", "Objectives"))

  # Keypoints are always the last block and should be auto-translated
  xpath_keypoints <- ".//div[@class='callout keypoints']//h3[@class='callout-title']"
  keypoints <- xml2::xml_find_first(xml, xpath_keypoints)
  expect_set_translated(keypoints, "Key Points")

  # Instructor note headings should be translated
  xpath_instructor <- ".//div[@class='accordion-item']/button/h3"
  instructor_note <- xml2::xml_find_all(xml, xpath_instructor)
  expect_set_translated(instructor_note, "Instructor Note")

  # solution headings should be translated
  xpath_solution <- ".//div[@class='accordion-item']/button/h4"
  solution <- xml2::xml_find_all(xml, xpath_solution)
  # take the last solution block because that's the one that does not have
  # a title.
  solution <- solution[[length(solution)]]

  expect_set_translated(solution, "Show me the solution")

})
