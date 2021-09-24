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
  "This [link should be transformed](../learners/Setup.md)",
  "", 
  "This [rmd link also](../episodes/01-Introduction.Rmd)",
  "",
  "This [rmd is safe](https://example.com/01-Introduction.Rmd)",
  "",
  "This [too](../learners/Setup.md#windows-setup 'windows setup')",
  "",
  "![link should be transformed](../episodes/fig/Setup.png){alt='alt text'}",
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



test_that("emoji are rendered", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  withr::local_file(tmp)
  writeLines("Emojis work :wink:", tmp)
  expect_match(render_html(tmp), "data-emoji", fixed = TRUE)
})

test_that("links are auto rendered", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  withr::local_file(tmp)
  writeLines("Links work: https://carpentries.org/.", tmp)
  expect_match(render_html(tmp), "href=", fixed = TRUE)
})


test_that("empty raw divs are still processed", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  withr::local_file(tmp)
  writeLines("<div>classless divs work</div>", tmp)
  expect_match(render_html(tmp), "classless divs work", fixed = TRUE)

})


test_that("footnotes are rendered", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  withr::local_file(tmp)
  writeLines("Footnotes work^[maybe they do?].", tmp)
  inline <- render_html(tmp)
  writeLines("Footnotes work[^1].\n\n[^1]: maybe they do?", tmp)
  ref <- render_html(tmp)
  expect_match(inline, "footnote-ref", fixed = TRUE)
  expect_match(ref, "footnote-ref", fixed = TRUE)
  expect_equal(inline, ref)
})

test_that("pandoc structure is rendered correctly", {
  
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  out <- fs::file_temp()
  withr::local_file(tmp, out)

  writeLines(ex, tmp)
  args <- construct_pandoc_args(tmp, out, to = "native")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  if (.Platform$OS.type == "windows" && Sys.getenv("CI", unset = '') == "true") {
    # let's see what this looks like
    message(cat(readLines(out), sep = "\n"))
  }
  skip_on_os("windows")
  expect_snapshot(cat(readLines(out), sep = "\n"))
})

test_that("paragraphs after objectives block are parsed correctly", {
  
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  out <- fs::file_temp()
  withr::local_file(tmp, out)

  ex2 <- c(ex[1:16], "", "Do you think he saurus?", ex[17:18])
  writeLines(ex2, tmp)
  args <- construct_pandoc_args(tmp, out, to = "native")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  if (.Platform$OS.type == "windows" && Sys.getenv("CI", unset = '') == "true") {
    # let's see what this looks like
    message(cat(readLines(out), sep = "\n"))
  }
  skip_on_os("windows")
  expect_snapshot(cat(readLines(out), sep = "\n"))

})

test_that("render_html applies the internal lua filter", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  tmp <- fs::file_temp()
  withr::local_file(tmp)

  writeLines(ex, tmp)
  res <- render_html(tmp)

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

  if (.Platform$OS.type == "windows" && Sys.getenv("CI", unset = '') == "true") {
    # let's see what this looks like
    message(res)
  }
  skip_on_os("windows")
  expect_snapshot(cat(res))

})

test_that("render_html applies external lua filters", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
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
