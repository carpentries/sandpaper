ex <- c("# Markdown", 
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
  NULL
)
test_that("render_html applies the internal lua filter", {

  tmp <- fs::file_temp()
  withr::local_file(tmp)

  writeLines(ex, tmp)
  res <- render_html(tmp)
  expect_snapshot(cat(res))
  # Challenge header automatically added
  expect_match(res, "Challenge</h2>", fixed = TRUE)
  # Solution header modified
  expect_match(res, "Write now</h2>", fixed = TRUE)
  # Aside tag applied
  expect_match(res, "<aside class=\"instructor\">", fixed = TRUE)
  # Instructor header doesn't need to exist
  expect_failure(expect_match(res, "Instructor</h2>", fixed = TRUE))


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
