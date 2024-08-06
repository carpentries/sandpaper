

test_that("paths in instructor view that are nested or not HTML get diverted", {
  html_test <- xml2::read_html(commonmark::markdown_html(c(
    "<a id='what-the'></a><h2>h</h2>\n",
    "[a](index.html)",
    "[b](./index.html)",
    "[c](fig/thing.png)",           # asset
    "[d](./fig/thang.jpg)",         # asset
    "[e](data/thing.csv)",          # asset
    "[f](files/papers/thing.pdf)",  # asset
    "[g](files/confirmation.html)", # asset
    "[h](#what-the)",
    "[i](other-page.html#section)",
    "[j](other-page)",
    "[k](mailto:workbench@example.com?subject='no')"
  )))
  res <- xml2::read_html(use_instructor(html_test))
  # refs are transformed according to our rules
  refs <- xml2::xml_text(xml2::xml_find_all(res, ".//@href"))
  expect_equal(startsWith(refs, "../"),
    c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_snapshot(xml2::xml_find_all(html_test, ".//a[@href]"))
  expect_snapshot(xml2::xml_find_all(res, ".//a[@href]"))
})



test_that("fix figures account for inline images and do not clobber them into figures", {
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  test_md <- fs::path_abs(test_path("examples/figures.md"))
  raw <- render_html(test_md)
  html <- xml2::read_html(raw)
  fix_figures(html)

  # there should be six images, but only two of them are figures
  figgies <- xml2::xml_find_all(html, ".//figure")
  kitties <- xml2::xml_find_all(html, ".//img")
  expect_length(figgies, 2L)
  expect_length(kitties, 7L)
  expected_classes <- c("figure", "figure", "figure",
    "figure mx-auto d-block", "figure mx-auto d-block", "figure", "figure")
  expect_equal(xml2::xml_attr(kitties, "class"), expected_classes)

  # The immediate parents of the kitties should be a link, list, paragraph, and
  # two figures and a paragraph.
  rents   <- xml2::xml_parent(kitties)
  expect_equal(xml2::xml_name(rents),
    c("a", "li", "p", "figure", "figure", "p"))
})



test_that("(#556) (#454) callout are processed correctly", {
  html_test <- xml2::read_html(test_path("examples/callout-ids.html"))
  fix_callouts(html_test)
  anchors <- xml2::xml_find_all(html_test, ".//a")
  headings <- xml2::xml_find_all(html_test, ".//h3")
  callouts <- xml2::xml_find_all(html_test,
    ".//div[starts-with(@class, 'callout ')]")

  # temporarily removed as a result of https://github.com/r-lib/pkgdown/issues/2737
  # expect_length(anchors, 2)

  expect_length(callouts, 2)
  expect_length(headings, 2)
  # headings should not have IDS
  expect_equal(xml2::xml_has_attr(headings, "id"), c(FALSE, FALSE))
  # callouts should have these IDS
  expect_equal(xml2::xml_has_attr(callouts, "id"), c(TRUE, TRUE))
  # The IDs should be what we expect
  ids <- xml2::xml_attr(callouts, "id")
  expect_equal(ids, c("discussion1", "wait-what"))

  # temporarily removed as a result of https://github.com/r-lib/pkgdown/issues/2737
  # The IDs should match the anchors
  # expect_equal(paste0("#", ids), xml2::xml_attr(anchors, "href"))

  # The headings should match what we expect
  # (https://github.com/carpentries/sandpaper/issues/556)
  htext <- xml2::xml_find_all(headings, ".//text()")
  expect_equal(xml2::xml_text(htext),
    c("Challenge (", "this is code", ")", "Wait what?"))
})


test_that("setup links with anchors are respected", {

  # See https://github.com/carpentries/sandpaper/issues/521
  html_txt <- paste0(
    "<a href='setup.html'>success</a>",
    "<a href='setup.html#troubleshooting'>success</a>",
    "<a href='index.html'>no change</a>",
    "<a href='https://example.com/setup.html#troubleshooting'>no change</a>",
    "<a href='example.com/setup.html#troubleshooting'>no change</a>",
    "<a href='https://example.com/setup.html'>no change</a>",
    "<a href='example.com/setup.html'>no change</a>"
  )
  html_expect <- paste0(
    "<a href='index.html#setup'>success</a>",
    "<a href='index.html#troubleshooting'>success</a>",
    "<a href='index.html'>no change</a>",
    "<a href='https://example.com/setup.html#troubleshooting'>no change</a>",
    "<a href='example.com/setup.html#troubleshooting'>no change</a>",
    "<a href='https://example.com/setup.html'>no change</a>",
    "<a href='example.com/setup.html'>no change</a>"
  )

  html <- xml2::read_html(html_txt)
  expect <- xml2::read_html(html_expect)

  # call the function for its side effect
  fix_setup_link(html)

  # test that both of the things are identical
  expect_equal(as.character(html), as.character(expect))

})


test_that("code block languages are in the correct order", {

  # SETUP ---------------------------------------------------
  html <- '<div class="sourceCode" id="cb1">
  <pre class="sourceCode bash">
  <code class="sourceCode bash"><span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a><span class="ex">shello</span></span>
  </code>
  </pre>
  </div>
  <div class="sourceCode" id="cb2">
  <pre class="sourceCode r">
  <code class="sourceCode r"><span id="cb2-1"><a href="#cb2-1" aria-hidden="true" tabindex="-1"></a>letters</span>
  </code>
  </pre>
  </div>'

  nodes <- xml2::read_html(html)

  # ABSENCE TESTS -------------------------------------------
  # By default, there are no h3 headings
  expect_length(xml2::xml_find_all(nodes, ".//h3"), 0L)
  xpath_codewrap <- ".//div[@class='codewrapper sourceCode']"
  expect_length(xml2::xml_find_all(nodes, xpath_codewrap), 0L)
  xpath_pre_tabindex <- ".//pre[@tabindex]"
  expect_length(xml2::xml_find_all(nodes, xpath_pre_tabindex), 0L)

  fix_codeblocks(nodes)

  # PRESENCE TESTS ------------------------------------------
  expect_length(xml2::xml_find_all(nodes, ".//h3"), 2L)
  expect_length(xml2::xml_find_all(nodes, xpath_codewrap), 2L)
  expect_length(xml2::xml_find_all(nodes, xpath_pre_tabindex), 2L)

  # after fixing, the h3 headings should be in the correct order
  heading_text <- xml2::xml_text(xml2::xml_find_all(nodes, ".//h3"))
  expect_equal(heading_text, c("BASH", "R"))

  # divs now have two children
  first_div <- xml2::xml_find_first(nodes, ".//div")
  expect_equal(xml2::xml_name(xml2::xml_children(first_div)), c("h3", "pre"))

  # the first pre block is a child of the first div
  first_pre <- xml2::xml_find_first(nodes, ".//pre")
  # the parent is _identical_ to the first_div because of how the xml2 package
  # works
  expect_identical(xml2::xml_parent(first_pre), first_div)
  expect_equal(xml2::xml_attr(first_pre, "class"), "sourceCode bash")
  # a tabindex attribute is added
  expect_equal(xml2::xml_attr(first_pre, "tabindex"), "0")

})



test_that("empty args result in nothing happening", {
  expect_null(fix_nodes())
  expect_null(fix_setup_link())
  expect_null(fix_headings())
  expect_null(fix_codeblocks())
  expect_null(add_code_heading())
  expect_null(fix_figures())
  expect_null(fix_callouts())
  expect_null(use_learner())
  expect_null(use_instructor())
})

test_that("NULL args result in nothing happening", {
  expect_null(fix_nodes(NULL))
  expect_null(fix_setup_link(NULL))
  expect_null(fix_headings(NULL))
  expect_null(fix_codeblocks(NULL))
  expect_null(add_code_heading(NULL))
  expect_null(fix_figures(NULL))
  expect_null(fix_callouts(NULL))
  expect_null(use_learner(NULL))
  expect_null(use_instructor(NULL))
})

test_that("empty character entries result in nothing happening", {
  expect_length(fix_nodes(character(0)), 0)
  expect_length(fix_setup_link(character(0)), 0)
  expect_length(fix_headings(character(0)), 0)
  expect_length(fix_codeblocks(character(0)), 0)
  expect_length(add_code_heading(character(0)), 0)
  expect_length(fix_figures(character(0)), 0)
  expect_length(fix_callouts(character(0)), 0)
  expect_length(use_learner(character(0)), 0)
  expect_length(use_instructor(character(0)), 0)
})

