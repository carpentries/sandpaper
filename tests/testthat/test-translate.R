# Generate temporary lesson and set `lang: ja` in config.yaml
tmp <- res <- restore_fixture()
config_path <- fs::path(tmp, "config.yaml")
config <- yaml::read_yaml(config_path)
config$lang <- "ja"
yaml::write_yaml(config, config_path)
sitepath <- fs::path(tmp, "site", "docs")

test_that("set_translations() uses english by default", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  # Before anything happens, the translations should match the source
  expect_equal(these$translations$src$computed, these$translations$computed)
  expect_equal(these$translations$src$varnish, these$translations$varnish)

  # default is english
  set_translations()

  # If the translations are set to english, the source should continue to match
  expect_equal(these$translations$src$computed, these$translations$computed)
  expect_equal(these$translations$src$varnish, these$translations$varnish)

  # confirm a specific source element
  src <- these$translations$src$computed$OUTPUT
  expect_equal(these$translations$computed$OUTPUT, src)

  # set to japanese and it becomes different
  set_translations("ja")
  expect_failure({
    expect_equal(these$translations$src$computed, these$translations$computed)
  })
  expect_failure({
    expect_equal(these$translations$src$varnish, these$translations$varnish)
  })
  OUTJA <- these$translations$computed$OUTPUT
  expect_failure(expect_equal(OUTJA, src))

  # unknown language will not switch the current language
  suppressMessages(expect_message(set_translations("xx"), "languages"))
  expect_equal(these$translations$computed$OUTPUT, OUTJA)

  # set back to english (default)
  set_translations()
  expect_equal(these$translations$computed$OUTPUT, src)

})


test_that("set_translations() can use country codes", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  src <- these$translations$src$computed$OUTPUT
  expect_silent(set_translations("es_AR"))
  OUTAR <- these$translations$computed$OUTPUT
  expect_false(identical(OUTAR, src))

  # the country codes will fall back to language code if they don't exist
  expect_silent(set_translations("es"))
  expect_equal(these$translations$computed$OUTPUT, OUTAR)

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
  # Testing both learner and instructor versions of this page
  xml <- xml2::read_html(fs::path(sitepath, "index.html"))
  instruct <- xml2::read_html(fs::path(sitepath, "instructor/index.html"))
  # language should be set to japanese
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")
  to_main <- xml2::xml_find_first(xml, "//a[@href='#main-content']")
  ito_main <- xml2::xml_find_first(instruct, "//a[@href='#main-content']")
  expect_set_translated(to_main, "Skip to main content")
  expect_set_translated(ito_main, "Skip to main content")

  expect_equal(xml2::xml_attr(instruct, "lang"), "ja")
  expect_title_translated(xml, "Summary and Setup")
  expect_title_translated(instruct, "Summary and Schedule")

  # Extract first header (Summary and Setup) from index
  h1_xpath <- "//h1[@class='schedule-heading']"
  h1_header <- xml2::xml_find_all(xml, h1_xpath)
  expect_set_translated(h1_header, "Summary and Setup")
  ih1_header <- xml2::xml_find_all(instruct, h1_xpath)
  expect_set_translated(ih1_header, "Summary and Schedule")

  # Schedule for instructor view ends with "Finish"
  final_cell <- xml2::xml_find_first(instruct, "//tr[last()]/td[2]")
  expect_set_translated(final_cell, "Finish")

  # Navbar has expected text
  nav_xpath <- "//a[starts-with(@class,'nav-link')]"
  nav_links <- xml2::xml_find_all(xml, nav_xpath)
  expect_set_translated(nav_links,
    c("Key Points", "Glossary", "Learner Profiles")
  )
  inav_links <- xml2::xml_find_all(instruct, nav_xpath)
  expect_set_translated(inav_links,
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
    "Next Chapter",
    "anchor",
    "Back To Top"
  )
  aria_labels <- xml2::xml_find_all(xml, ".//@aria-label")
  iaria_labels <- xml2::xml_find_all(instruct, ".//@aria-label")
  expect_set_translated(aria_labels, aria_text)
  expect_set_translated(iaria_labels, aria_text)


  # GENERATED PAGES ------------------------------------------------
  # These pages should have translated headers and title elements
  inst_notes_path <- fs::path(sitepath, "instructor/instructor-notes.html")
  inst_notes <- xml2::read_html(inst_notes_path)
  expect_equal(xml2::xml_attr(inst_notes, "lang"), "ja")
  expect_h1_translated(inst_notes, "Instructor Notes")
  expect_title_translated(inst_notes, "Instructor Notes")

  profiles <- xml2::read_html(fs::path(sitepath, "profiles.html"))
  expect_equal(xml2::xml_attr(profiles, "lang"), "ja")
  expect_h1_translated(profiles, "Learner Profiles")
  expect_title_translated(profiles, "Learner Profiles")

  fof <- xml2::read_html(fs::path(sitepath, "404.html"))
  expect_equal(xml2::xml_attr(fof, "lang"), "ja")
  expect_h1_translated(fof, "Page not found")
  expect_title_translated(fof, "Page not found")

  imgs <- xml2::read_html(fs::path(sitepath, "instructor/images.html"))
  expect_equal(xml2::xml_attr(imgs, "lang"), "ja")
  expect_title_translated(imgs, "All Images")


  # Episode elements -------------------------------------------------
  # We use here the Instructor view because it is more fully featured
  # NOTE: we expect this to be the first episode after the home page
  xml <- xml2::read_html(fs::path(sitepath, "instructor", "introduction.html"))
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")
  to_main <- xml2::xml_find_first(xml, "//a[@href='#main-content']")
  expect_set_translated(to_main, "Skip to main content")
  previous <- xml2::xml_find_all(xml, "//a[@class='chapter-link']")
  expect_set_translated(previous, c("Home", "Previous"))

  # navbar has expected text
  nav_links <- xml2::xml_find_all(xml, "//a[starts-with(@class,'nav-link')]")
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
