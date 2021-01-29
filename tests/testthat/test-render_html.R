ex <- c("---",
  "teaching: 6",
  "exercises: 9",
  "---",
  "",
  "::: questions", 
  "", 
  " - What's the point?",
  "", 
  ":::",
  "",
  "::: objectives", 
  "", 
  " - Bake him away, toys",
  "", 
  ":::",
  "",
  "# Markdown", 
  "", 
  "::: challenge", 
  "", 
  "How do you write markdown divs?",
  "", 
  "::: solution",
  "",
  "# Write now",
  "",
  "just write it, silly.",
  ":::",
  ":::",
  "", 
  "::: instructor", 
  "", 
  "This should be aside",
  "", 
  ":::",
  "", 
  "::: nothing", 
  "", 
  "This should be",
  "", 
  ":::",
  NULL
)

test_that("pandoc_json is rendered correctly", {
  
  skip_if_not_installed("jsonlite")
  skip_if_not(rmarkdown::pandoc_available("2.10"))
  tmp <- fs::file_temp()
  out <- fs::file_temp()
  withr::local_file(tmp, out)

  writeLines(ex, tmp)
  args <- construct_pandoc_args(tmp, out, to = "json")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  expect_snapshot(jsonlite::prettify(readLines(out), indent = 2))

})

test_that("paragraphs after objectives block are parsed correctly", {
  
  skip_if_not(rmarkdown::pandoc_available("2.10"))
  tmp <- fs::file_temp()
  withr::local_file(tmp)

  ex2 <- c(ex[1:16], "", "Do you think he saurus?", ex[17:18])
  writeLines(ex2, tmp)
  expect_snapshot(cat(render_html(tmp)))

})

test_that("render_html applies the internal lua filter", {

  tmp <- fs::file_temp()
  withr::local_file(tmp)

  writeLines(ex, tmp)
  res <- render_html(tmp)
  
  if (rmarkdown::pandoc_available("2.10")) {
    expect_snapshot(cat(res))
  }

  # Metadata blocks are parsed
  expect_match(res, "div class=\"row\"", fixed = TRUE)
  expect_match(res, "div class=\"col-md-3\"", fixed = TRUE)
  expect_match(res, "div class=\"col-md-9\"", fixed = TRUE)
  expect_match(res, "div class=\"section level2 objectives\"", fixed = TRUE)
  expect_match(res, "Teaching: ", fixed = TRUE)
  expect_match(res, "Exercises: ", fixed = TRUE)
  expect_match(res, "Questions", fixed = TRUE)
  expect_match(res, "Objectives", fixed = TRUE)
  # Challenge header automatically added
  expect_match(res, "Challenge</h2>", fixed = TRUE)
  # Solution header modified
  expect_match(res, "Write now</h2>", fixed = TRUE)
  # Aside tag applied
  expect_match(res, "<aside class=\"instructor\">", fixed = TRUE)
  # Instructor header doesn't need to exist
  expect_failure(expect_match(res, "Instructor</h2>", fixed = TRUE))
  # Div class nothing should be left alone
  expect_match(res, "div class=\"nothing\"", fixed = TRUE)
  expect_failure(expect_match(res, "Nothing</h2>", fixed = TRUE))

})

test_that("render_html applies external lua filters", {

  tmp <- fs::file_temp()
  lua <- fs::file_temp()
  withr::local_file(tmp, lua)

  writeLines(ex, tmp)
  lu <- c("Str = function (elem)",
    "  if elem.text == 'markdown' then",
    "    return pandoc.Emph {pandoc.Str 'mowdrank'}",
    "  end",
    "end")
  writeLines(lu, lua)
  res <- render_html(tmp, paste0("--lua-filter=", lua))
  expect_match(res, "<em>mowdrank</em> divs", fixed = TRUE)
  
})
