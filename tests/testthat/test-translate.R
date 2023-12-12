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

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  # Build lesson
  suppressMessages(build_lesson(tmp, preview = FALSE, quiet = TRUE))
  
  # GENERATED PAGES ------------------------------------------------
  # Check generated page headers
  inst_note <- xml2::read_html(fs::path(sitepath, "instructor/instructor-notes.html"))
  h1_inst <- xml2::xml_find_first(inst_note, "//main/div/h1")
  expect_equal(
    xml2::xml_text(h1_inst),
    withr::with_language("ja", tr_("Instructor Notes"))
  )
  expect_false(
    identical(
      xml2::xml_text(h1_inst),
      withr::with_language("en", tr_("Instructor Notes"))
    )
  )
  profiles <- xml2::read_html(fs::path(sitepath, "profiles.html"))
  h1_profiles <- xml2::xml_find_first(profiles, "//main/div/h1")
  expect_equal(
    xml2::xml_text(h1_profiles),
    withr::with_language("ja", tr_("Learner Profiles"))
  )
  expect_false(
    identical(
      xml2::xml_text(h1_profiles),
      withr::with_language("en", tr_("Learner Profiles"))
    )
  )


  # Extract first header (Summary and Setup) from index
  xml <- xml2::read_html(fs::path(sitepath, "index.html"))
  h1_header <- xml2::xml_find_all(xml, "//h1[@class='schedule-heading']")
  nav_links <- xml2::xml_find_all(xml, "//a[starts-with(@class,'nav-link')]")

  # language should be set to japanese
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")

  # Header should be translated to Japanese
  expect_true(
    identical(
      xml2::xml_text(h1_header),
      withr::with_language("ja", tr_("Summary and Setup"))
    )
  )
  # Navbar has expected text
  expect_equal(
    xml2::xml_text(nav_links),
    withr::with_language("ja", 
      c(tr_("Key Points"), tr_("Glossary"), tr_("Learner Profiles"))
    )
  )
  expect_false(
    identical(
      xml2::xml_text(nav_links),
      withr::with_language("en", 
        c(tr_("Key Points"), tr_("Glossary"), tr_("Learner Profiles"))
      )
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

  # Episode elements -------------------------------------------------
  # We use here the Instructor view because it is more fully featured
  xml <- xml2::read_html(fs::path(sitepath, "instructor", "introduction.html"))
  nav_links <- xml2::xml_find_all(xml, "//a[starts-with(@class,'nav-link')]")

  # navbar has expected text
  expect_equal(
    xml2::xml_text(nav_links),
    withr::with_language("ja", 
      c(tr_("Key Points"), tr_("Instructor Notes"), tr_("Extract All Images"))
    )
  )
  expect_false(
    identical(
      xml2::xml_text(nav_links),
      withr::with_language("en", 
        c(tr_("Key Points"), tr_("Instructor Notes"), tr_("Extract All Images"))
      )
    )
  )

  # overview, objectives, and questions
  overview_card <- xml2::xml_find_first(xml, ".//div[@class='overview card']")

  # Overview card
  overview <- xml2::xml_find_first(overview_card, ".//h2[@class='card-header']")
  expect_equal(
    xml2::xml_text(overview, trim = TRUE),
    withr::with_language("ja", tr_("Overview"))
  )
  expect_false(
    identical(
      xml2::xml_text(overview, trim = TRUE),
      withr::with_language("en", tr_("Overview"))
    )
  )

  # Questions and Objectives
  quob <- xml2::xml_find_all(overview_card, ".//h3[@class='card-title']")
  expect_equal(
    xml2::xml_text(quob, trim = TRUE),
    withr::with_language("ja", c(tr_("Questions"), tr_("Objectives")))
  )
  expect_false(
    identical(
      xml2::xml_text(quob, trim = TRUE),
    withr::with_language("en", c(tr_("Questions"), tr_("Objectives")))
    )
  )

  # Keypoints are always the last block and should be auto-translated
  xpath_keypoints <- ".//div[@class='callout keypoints']//h3[@class='callout-title']"
  keypoints <- xml2::xml_find_first(xml, xpath_keypoints)
  expect_equal(
    xml2::xml_text(keypoints, trim = TRUE),
    withr::with_language("ja", tr_("Key Points"))
  )
  expect_false(
    identical(
      xml2::xml_text(keypoints, trim = TRUE),
      withr::with_language("en", tr_("Key Points"))
    )
  )

  # Instructor note headings should be translated
  xpath_instructor <- ".//div[@class='accordion-item']/button/h3"
  instructor_note <- xml2::xml_find_all(xml, xpath_instructor)
  expect_equal(
    xml2::xml_text(instructor_note, trim = TRUE),
    withr::with_language("ja", tr_("Instructor Note"))
  )
  expect_false(
    identical(
      xml2::xml_text(instructor_note, trim = TRUE),
      withr::with_language("en", tr_("Instructor Note"))
    )
  )

  # solution headings should be translated
  xpath_solution <- ".//div[@class='accordion-item']/button/h4"
  solution <- xml2::xml_find_all(xml, xpath_solution)
  # take the last solution block because that's the one that does not have
  # a title.
  solution <- solution[[length(solution)]]
  expect_equal(
    xml2::xml_text(solution, trim = TRUE),
    withr::with_language("ja", tr_("Show me the solution"))
  )
  expect_false(
    identical(
      xml2::xml_text(solution, trim = TRUE),
      withr::with_language("en", tr_("Show me the solution"))
    )
  )

})
