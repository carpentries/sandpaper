
test_that("sidebar headings can contain html within", {
  html <- "<section id='plotting'>
  <h2 class='section-heading'>Plotting with <strong><code>ggplot2</code></strong>
  <p>This is how you plot with <code>ggplot2</code></p>
  </section>
  <section id='building'>
  <h2 class='section-heading'>Building your plots iteratively</h2>
  <p>This is how you build your plots iteratively</p>
  </section>"
  nodes <- xml2::read_html(html)
  headings <- create_sidebar_headings(nodes)
  expect_type(headings, "character")
  li <- xml2::xml_find_all(xml2::read_html(headings), "./body/*")
  # The result is a list element with two items
  expect_length(li, 2)
  # one heading has a child node within
  expect_equal(xml2::xml_length(xml2::xml_children(li)),
    c(1, 0))
  # the anchors are the URIs
  expect_equal(xml2::xml_text(xml2::xml_find_all(li, ".//@href")),
    c("#plotting", "#building"))
})

# # NOTE: 2023-05-29 I believe this test is sort of defunct because we are
# # testing here how to create a sidebar given a specific episode, but we no
# # longer use this pattern in the lesson, so this test and the `name` option
# # for `create_sidebar()` should be removed.
# # NOTE: 2025-09-19 This test has been commented out for future removal
# test_that("a sidebar can be created with a specific episode and will have sequential numbers", {
#   mockr::local_mock(get_navbar_info = function(i) {
#     list(pagetitle = toupper(i), text = paste("text", i), href = as_html(i))
#   })
#   html <- "<section id='plotting'>
#   <h2 class='section-heading'>Plotting with <strong><code>ggplot2</code></strong>
#   <p>This is how you plot with <code>ggplot2</code></p>
#   </section>
#   <section id='building'>
#   <h2 class='section-heading'>Building your plots iteratively</h2>
#   <p>This is how you build your plots iteratively</p>
#   </section>"
#   chapters <- c("index.md", "one.md", "two.md", "three.md")
#   sb <- create_sidebar(chapters, name = "two.md", html = html)
#   expect_snapshot(writeLines(sb))

# })


test_that("updating a sidebar for all pages modifies appropriately", {

  mockr::local_mock(get_navbar_info = function(i) {
    list(pagetitle = toupper(i), text = paste("text", i), href = as_html(i))
  })
  html <- "<section id='plotting'>
  <h2 class='section-heading'>Plotting with <strong><code>ggplot2</code></strong>
  <p>This is how you plot with <code>ggplot2</code></p>
  </section>
  <section id='building'>
  <h2 class='section-heading'>Building your plots iteratively</h2>
  <p>This is how you build your plots iteratively</p>
  </section>"
  chapters <- c("index.md", "one.md", "two.md", "three.md")
  sb <- create_sidebar(chapters, html = html)
  extra_store <- .list_store()
  extra_store$update(c(list(sidebar = sb), get_navbar_info("images.md")))
  ep_store <- extra_store$copy()

  xhtml <- xml2::read_html(html)

  # sidebar update of _extra_ content will _not_ update the sidebar -----------
  update_sidebar(extra_store, xhtml, "images.html")
  expect_length(extra_store$get()[["sidebar"]], 1L)
  expect_identical(extra_store$get()[["sidebar"]], paste(sb, collapse = "\n"))
  extra_nodes <- xml2::read_html(extra_store$get()[["sidebar"]])
  extra_current <- xml2::xml_find_all(extra_nodes, ".//span[@class='current-chapter']")
  expect_length(extra_current, 0L)

  # sidebar update of episode content will update the sidebar -----------------
  ep_store$update(get_navbar_info("two.md"))
  update_sidebar(ep_store, xhtml, "two.html")
  expect_length(ep_store$get()[["sidebar"]], 1L)
  expect_false(identical(ep_store$get()[["sidebar"]], paste(sb, collapse = "\n")))
  ep_nodes <- xml2::read_html(ep_store$get()[["sidebar"]])
  ep_current <- xml2::xml_find_all(ep_nodes, ".//span[@class='current-chapter']")
  expect_length(ep_current, 1L)

})



test_that("fix_sidebar_href will return empty string if given empty string", {

  expect_equal(fix_sidebar_href("", server = "exampe.com"), "")
  expect_equal(fix_sidebar_href(character(0), server = "exampe.com"), "")
  expect_equal(fix_sidebar_href(NULL, server = "exampe.com"), "")
  expect_equal(fix_sidebar_href(1:3, server = "exampe.com"), "")
  expect_equal(fix_sidebar_href(list(), server = "exampe.com"), "")


})

