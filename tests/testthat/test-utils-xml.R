

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
    "[j](other-page)"
  )))
  res <- xml2::read_html(use_instructor(html_test))
  # refs are transformed according to our rules
  refs <- xml2::xml_text(xml2::xml_find_all(res, ".//@href"))
  expect_equal(startsWith(refs, "../"),
    c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE))
  expect_snapshot(xml2::xml_find_all(html_test, ".//a[@href]"))
  expect_snapshot(xml2::xml_find_all(res, ".//a[@href]"))
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

