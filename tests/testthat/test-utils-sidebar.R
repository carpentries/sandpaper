
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


test_that("a sidebar can be and will have sequential numbers", {

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
  expect_snapshot(writeLines(create_sidebar(chapters, name = "two.md", html = html)))
})


