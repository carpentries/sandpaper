# Generate temporary lesson and set `lang: ja` in config.yaml
tmp <- res <- restore_fixture()
config_path <- fs::path(tmp, "config.yaml")
config <- yaml::read_yaml(config_path)
config$lang <- "ja"
yaml::write_yaml(config, config_path)
sitepath <- fs::path(tmp, "site", "docs")

# A Note on the conventions of this test file
# -------------------------------------------
#
# The majority of the tests in this file are testing on the rendered version
# of the lesson that is created above. The lesson is built and then all of the
# tests for specific keys are run after it. You can find where it builds by
# searching for a series of equals signs: =======
#
# The `helper-translate.R` file contains three functions. These functions will
# actively test the `tr_()` function, which acts on the VALUES and they test
# that the text in an HTML node matches the translated text AND that it DOES NOT
# match the English text.
#
#  - expect_set_translated() will take in an HTML node and the values to test
#    against a known language (ja)
#  - expect_title_translated() does the same, except it will test that the
#    <title> element is translated, which is useful for generated pages
#  - expect_h1_tranlsated() does the same, except it tests for the H1 element,
#    which is useful for generated pages that have h1 headings.
#
# When we test translations, it's important to use the KEYS and not the VALUES
# for the translations, which will come from the `tr_src()` function. The early
# tests will confirm that the `tr_src()` function contains the source strings
# and the `tr_varnish()` and `tr_computed()` functions contain the translated
# strings.
#
# good:
#   expect_set_translated(node,
#     tr_src("varnish", "LearnerProfiles")
#   )
#   expect_set_translated(nodeset,
#     c(
#       tr_src("varnish", "KeyPoints"),
#       tr_src("varnish", "Glossary"),
#       tr_src("varnish", "LearnerProfiles")
#     )
#   )
# bad:
#   expect_set_translated(node, "Learner Profiles")
#   expect_set_translated(nodeset,
#     c("Key Points", "Glossary", "Learner Profiles")
#   )
#
# The reason for this convention is two-fold:
#
# 1. using tr_src(collection, key) allows us to confirm that a given key is
#    found in a specific collection.
# 2. we can change the values and confirm that the tests work without changing
#    the tests.
#
# That's it. Happy testing, don't die!

test_that("tr_ helpers will extract the source", {

  expect_equal(these$translations$src$computed, tr_src("computed"))
  expect_equal(these$translations$src$varnish, tr_src("varnish"))

  # different collections should not be equivalent
  expect_failure({
    expect_equal(tr_src("varnish"), tr_src("computed"))
  })
})


test_that("set_language() uses english by default and test helpers are valid", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  # Before anything happens, the translations should match the source
  expect_equal(tr_computed(), tr_src("computed"))
  expect_equal(tr_varnish(), tr_src("varnish"))

  # translations should not match their reciprocal
  expect_failure({
    expect_equal(tr_computed(), tr_src("varnish"))
  })
  expect_failure({
    expect_equal(tr_varnish(), tr_src("computed"))
  })

  # default is english
  set_language()

  # If the translations are set to english, the source should continue to match
  expect_equal(tr_computed(), tr_src("computed"))
  expect_equal(tr_varnish(), tr_src("varnish"))

  # confirm a specific source element
  src <- tr_src("computed", "OUTPUT")
  expect_equal(src, tr_computed("OUTPUT"))

  # set to japanese and it becomes different
  set_language("ja")
  expect_failure({
    expect_equal(tr_computed(), tr_src("computed"))
  })
  expect_failure({
    expect_equal(tr_varnish(), tr_src("varnish"))
  })
  OUTJA <- tr_computed("OUTPUT")
  expect_failure(expect_equal(OUTJA, src))

  # unknown language will not switch the current language
  suppressMessages(expect_message(set_language("xx"), "languages"))
  expect_equal(tr_computed("OUTPUT"), OUTJA)

  # set back to english (default)
  set_language()
  expect_equal(tr_computed("OUTPUT"), src)

})


test_that("set_language() can use country codes", {

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  src <- tr_src("computed")$OUTPUT
  expect_silent(set_language("es_AR"))
  OUTAR <- tr_computed("OUTPUT")
  expect_false(identical(OUTAR, src))

  # the country codes will fall back to language code if they don't exist
  expect_silent(set_language("es"))
  expect_equal(tr_computed("OUTPUT"), OUTAR)

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

  # NOTE: this requires the following functions defined in
  # tests/testthat/helper-translate.R:
  #  - expect_set_translated()
  #  - expect_title_translated()
  #  - expect_h1_translated()

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  os <- tolower(Sys.info()[["sysname"]])
  ver <- getRversion()
  skip_if(os == "windows" && ver < "4.2")

  # Build lesson ===================================================
  suppressMessages(build_lesson(tmp, preview = FALSE, quiet = TRUE))


  # Home Page ------------------------------------------------------
  # Testing both learner and instructor versions of this page
  xml <- xml2::read_html(fs::path(sitepath, "index.html"))
  instruct <- xml2::read_html(fs::path(sitepath, "instructor/index.html"))
  # language should be set to japanese
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")
  to_main <- xml2::xml_find_first(xml, "//a[@href='#main-content']")
  ito_main <- xml2::xml_find_first(instruct, "//a[@href='#main-content']")
  expect_set_translated(to_main,
    tr_src("varnish", "SkipToMain")
  )
  expect_set_translated(ito_main,
    tr_src("varnish", "SkipToMain")
  )

  expect_equal(xml2::xml_attr(instruct, "lang"), "ja")
  expect_title_translated(xml,
    tr_src("computed", "SummaryAndSetup")
  )
  expect_title_translated(instruct,
    tr_src("computed", "SummaryAndSchedule")
  )

  # Extract first header (Summary and Setup) from index
  h1_xpath <- "//h1[@class='schedule-heading']"
  h1_header <- xml2::xml_find_all(xml, h1_xpath)
  expect_set_translated(h1_header,
    tr_src("computed", "SummaryAndSetup")
  )
  ih1_header <- xml2::xml_find_all(instruct, h1_xpath)
  expect_set_translated(ih1_header,
    tr_src("computed", "SummaryAndSchedule")
  )

  # Schedule for instructor view ends with "Finish"
  final_cell <- xml2::xml_find_first(instruct, "//tr[last()]/td[2]")
  expect_set_translated(final_cell,
    tr_src("computed", "Finish")
  )

  # Navbar has expected text
  nav_xpath <- "//a[starts-with(@class,'nav-link')]"
  nav_links <- xml2::xml_find_all(xml, nav_xpath)
  expect_set_translated(nav_links,
    c(tr_src("varnish", "KeyPoints"),
      tr_src("varnish", "Glossary"),
      tr_src("varnish", "LearnerProfiles")
    )
  )
  inav_links <- xml2::xml_find_all(instruct, nav_xpath)
  expect_set_translated(inav_links,
    c(tr_src("varnish", "KeyPoints"),
      tr_src("varnish", "InstructorNotes"),
      tr_src("varnish", "ExtractAllImages")
    )
  )

# temporarily removed as a result of https://github.com/r-lib/pkgdown/issues/2737
#   # aria labels should be translated
#   aria_text <- c(
#     tr_src("varnish", "MainNavigation"),
#     tr_src("varnish", "ToggleNavigation"),
#     tr_src("varnish", "ToggleDarkMode"),
#     tr_src("varnish", "Search"),
#     tr_src("varnish", "SearchButton"),
#     tr_src("varnish", "LessonProgress"),
#     tr_src("varnish", "CloseMenu"),
#     tr_src("varnish", "NextChapter"),
#     # tr_src("computed", "Anchor"),
#     tr_src("varnish", "BackToTop")
#   )
#   aria_labels <- xml2::xml_find_all(xml, ".//@aria-label[@class!='anchor']")
#   iaria_labels <- xml2::xml_find_all(instruct, ".//@aria-label[@class!='anchor']")
#   expect_set_translated(aria_labels, aria_text)
#   expect_set_translated(iaria_labels, aria_text)


  # GENERATED PAGES ------------------------------------------------
  # These pages should have translated headers and title elements
  inst_notes_path <- fs::path(sitepath, "instructor/instructor-notes.html")
  inst_notes <- xml2::read_html(inst_notes_path)
  expect_equal(xml2::xml_attr(inst_notes, "lang"), "ja")
  expect_h1_translated(inst_notes,
    tr_src("varnish", "InstructorNotes")
  )
  expect_title_translated(inst_notes,
    tr_src("varnish", "InstructorNotes")
  )

  profiles <- xml2::read_html(fs::path(sitepath, "profiles.html"))
  expect_equal(xml2::xml_attr(profiles, "lang"), "ja")
  expect_h1_translated(profiles,
    tr_src("varnish", "LearnerProfiles")
  )
  expect_title_translated(profiles,
    tr_src("varnish", "LearnerProfiles")
  )

  fof <- xml2::read_html(fs::path(sitepath, "404.html"))
  expect_equal(xml2::xml_attr(fof, "lang"), "ja")
  expect_h1_translated(fof,
    tr_src("computed", "PageNotFound")
  )
  expect_title_translated(fof,
    tr_src("computed", "PageNotFound")
  )

  imgs <- xml2::read_html(fs::path(sitepath, "instructor/images.html"))
  expect_equal(xml2::xml_attr(imgs, "lang"), "ja")
  expect_title_translated(imgs,
    tr_src("computed", "AllImages")
  )


  # Episode elements -------------------------------------------------
  # We use here the Instructor view because it is more fully featured
  # NOTE: we expect this to be the first episode after the home page
  xml <- xml2::read_html(fs::path(sitepath, "instructor", "introduction.html"))
  expect_equal(xml2::xml_attr(xml, "lang"), "ja")
  to_main <- xml2::xml_find_first(xml, "//a[@href='#main-content']")
  expect_set_translated(to_main, tr_src("varnish", "SkipToMain"))
  previous <- xml2::xml_find_all(xml, "//a[@class='chapter-link']")
  expect_set_translated(previous, c(
      tr_src("varnish", "Home"),
      tr_src("varnish", "Previous")
    )
  )

  # navbar has expected text
  nav_links <- xml2::xml_find_all(xml, "//a[starts-with(@class,'nav-link')]")
  expect_set_translated(nav_links,
    c(tr_src("varnish", "KeyPoints"),
      tr_src("varnish", "InstructorNotes"),
      tr_src("varnish", "ExtractAllImages")
    )
  )

# temporarily removed as a result of https://github.com/r-lib/pkgdown/issues/2737
#   # aria labels should be translated
#   aria_text <- c(
#     tr_src("varnish", "MainNavigation"),
#     tr_src("varnish", "ToggleNavigation"),
#     tr_src("varnish", "ToggleDarkMode"),
#     tr_src("varnish", "Search"),
#     tr_src("varnish", "SearchButton"),
#     tr_src("varnish", "LessonProgress"),
#     tr_src("varnish", "CloseMenu"),
#     tr_src("varnish", "PreviousAndNext"),
#     # tr_src("computed", "Anchor"),
#     tr_src("varnish", "BackToTop")
#   )
#   aria_labels <- xml2::xml_find_all(xml, ".//@aria-label[@class!='anchor']")
#   expect_set_translated(aria_labels, aria_text)

  # overview, objectives, and questions
  overview_card <- xml2::xml_find_first(xml, ".//div[@class='overview card']")
  over_heads <- xml2::xml_find_all(overview_card, ".//h2 | .//h3")
  expect_set_translated(over_heads,
    c(tr_src("computed", "Overview"),
      tr_src("computed", "Questions"),
      tr_src("computed", "Objectives")
    )
  )

  # Keypoints are always the last block and should be auto-translated
  xpath_keypoints <- ".//div[@class='callout keypoints']//h3[@class='callout-title']"
  keypoints <- xml2::xml_find_first(xml, xpath_keypoints)
  expect_set_translated(keypoints,
    tr_src("computed", "Keypoints")
  )

  # Instructor note headings should be translated
  xpath_instructor <- ".//div[@class='accordion-item']/button/h3"
  instructor_note <- xml2::xml_find_all(xml, xpath_instructor)

  expect_set_translated(instructor_note,
    tr_src("computed", "Instructor Note")
  )

  # solution headings should be translated
  xpath_solution <- ".//div[@class='accordion-item']/button/h4"
  solution <- xml2::xml_find_all(xml, xpath_solution)
  # take the last solution block because that's the one that does not have
  # a title.
  # print(solution)
  solution <- solution[[length(solution)]]

  expect_set_translated(solution,
    tr_src("computed", "Show me the solution")
  )

})
