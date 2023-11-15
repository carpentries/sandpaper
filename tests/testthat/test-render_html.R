example_markdown <- fs::path_abs(test_path("examples", "ex.md"))


test_that("sandpaper.links can be included", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- withr::local_tempfile()
  tnk <- withr::local_tempfile()
  writeLines("This has a [link at the end] in a separate file[^1]\n\n[^1]: :)", tmp)
  writeLines("[link at the end]: https://example.com/link", tnk)
  withr::local_options(list("sandpaper.links" = tnk))
  expect_no_match(render_html(tmp), "\\[link at the end\\]")
})

test_that("sandpaper.links can be included even with read-only template file", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- withr::local_tempfile()
  tnk <- withr::local_tempfile()
  writeLines("This has a [link at the end] in a separate file[^1]\n\n[^1]: :)", tmp)

  perm <- fs::file_info(tmp)$permissions
  withr::defer(fs::file_chmod(tmp, perm), priority = "first")
  fs::file_chmod(tmp, "a-w")
  writeLines("[link at the end]: https://example.com/link", tnk)
  withr::local_options(list("sandpaper.links" = tnk))
  expect_no_match(render_html(tmp), "\\[link at the end\\]")
})

test_that("tabs are preserved", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  withr::local_file(tmp)
  writeLines("```python\nfor i in range(3):\n\tprint(i)\n\n```\n", tmp)
  expect_match(render_html(tmp), "\t")
})


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
  out <- fs::file_temp()
  withr::local_file(out)

  args <- construct_pandoc_args(example_markdown, out, to = "native")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  formation = function(x) {
    rgx <- "(data-bs-parent|aria-labelledby).+?(Instructor|Solution|Spoiler)1"
    return(sub(rgx, "[\\2 hidden]", x))
  }
  ver <- as.character(rmarkdown::pandoc_version())
  expect_snapshot(
    cat(readLines(out), sep = "\n"),
    transform = formation,
    variant = ver
  )
})

test_that("paragraphs after objectives block are parsed correctly", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  tmp <- fs::file_temp()
  out <- fs::file_temp()
  withr::local_file(tmp, out)

  ex <- readLines(example_markdown)
  ex2 <- c(ex[1:16], "", "Do you think he saurus?", ex[17:18])
  writeLines(ex2, tmp)
  args <- construct_pandoc_args(tmp, out, to = "native")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  ver <- as.character(rmarkdown::pandoc_version())
  expect_snapshot(cat(readLines(out), sep = "\n"), variant = ver)

})

test_that("render_html applies the internal lua filter", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  res <- as.character(render_html(example_markdown))

  # Metadata blocks are parsed
  expect_match(res, "div class=\"overview card\"", fixed = TRUE)
  expect_match(res, "div class=\"col-md-4\"", fixed = TRUE)
  expect_match(res, "div class=\"col-md-8\"", fixed = TRUE)
  expect_match(res, "div class=\"card-body\"", fixed = TRUE)
  expect_match(res, "Questions", fixed = TRUE)
  expect_match(res, "Objectives", fixed = TRUE)
  # Challenge header automatically added
  expect_match(res, "div id=\"challenge1\"", fixed = TRUE)
  expect_match(res, "<h3 class=\"callout-title\">Challenge</h3>", fixed = TRUE)
  # Solution header modified
  expect_match(res, "<h4 class=\"accordion-header\" id=\"headingSolution1\"")
  expect_match(res, "Write now", fixed = TRUE)
  # Aside tag applied
  expect_match(res, "<div id=\"accordionInstructor1\"", fixed = TRUE)
  # Instructor header doesn't need to exist
  expect_failure(expect_match(res, "Instructor</h2>", fixed = TRUE))
  # Div class nothing should be left alone
  expect_match(res, "div class=\"nothing\"", fixed = TRUE)
  expect_failure(expect_match(res, "Nothing</h2>", fixed = TRUE))

  formation = function(x) {
    open <- "[<]div id[=]\"collapse(Instructor|Solution|Spoiler)\\d\".+"
    mid  <- "(data-bs-parent|aria-labelledby).+?(Instructor|Solution|Spoiler)\\d[\"]$"
    close <- "(data-bs-parent|aria-labelledby).+?(Instructor|Solution|Spoiler)\\d.+[>]$"
    x <- sub(open, "<div id=\"\\1-[hidden...\"", x)
    x <- sub(mid, "...still hiding...", x)
    x <- sub(close, "...done]>", x)
    return(x)
  }
  ver <- as.character(rmarkdown::pandoc_version())
  expect_snapshot(cat(res), transform = formation, variant = ver)
})


example_instructor <- fs::path_abs(test_path("examples", "instructor-note.md"))

test_that("accordion lua filter parses instructor notes correctly", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  out <- fs::file_temp()
  withr::local_file(out)

  args <- construct_pandoc_args(example_instructor, out, to = "native")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  res <- render_html(example_instructor)
  expect_match(res, "<div id=\"accordionInstructor1\"", fixed = TRUE)
})

example_challenge <- fs::path_abs(test_path("examples", "challenge-hint.md"))

test_that("accordion lua filter parses challenge accordions correctly", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  out <- fs::file_temp()
  withr::local_file(out)

  args <- construct_pandoc_args(example_challenge, out, to = "native")
  callr::r(function(...) rmarkdown::pandoc_convert(...), args = args)
  res <- render_html(example_challenge)
  expect_match(res, "<div id=\"accordionHint1\"", fixed = TRUE)
  expect_match(res, "<div id=\"accordionSolution1\"", fixed = TRUE)
})

example_challenge2 <- fs::path_abs(test_path("examples", "challenge-multi.md"))

test_that("accordion lua filter parses post-solution text accordingly", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  res <- render_html(example_challenge2)
  expect_match(res, "<div id=\"accordionHint1\"", fixed = TRUE)
  expect_match(res, "<div id=\"accordionSolution1\"", fixed = TRUE)
  expect_match(res, "<div id=\"discussion1\"", fixed = TRUE)
})


test_that("render_html applies external lua filters", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))
  lua <- fs::file_temp()
  withr::local_file(lua)

  lu <- c("Str = function (elem)",
    "  if elem.text == 'markdown' then",
    "    return pandoc.Emph {pandoc.Str 'mowdrank'}",
    "  end",
    "end")
  writeLines(lu, lua)
  res <- render_html(example_markdown, paste0("--lua-filter=", lua))
  expect_match(res, "<em>mowdrank</em> divs", fixed = TRUE)

})
