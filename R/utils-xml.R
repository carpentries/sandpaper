fix_nodes <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  fix_headings(nodes)
  fix_callouts(nodes)
  fix_codeblocks(nodes)
  fix_figures(nodes)
}

fix_headings <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  # find all the div items that are purely section level 2
  h2 <- xml2::xml_find_all(nodes, ".//div[not(parent::div)][@class='section level2']/h2")
  xml2::xml_set_attr(h2, "class", "section-heading")
  xml2::xml_add_sibling(h2, "hr", class = "half-width", .where = "after")
  sections <- xml2::xml_parent(h2)
  xml2::xml_set_name(sections, "section")
  xml2::xml_set_attr(sections, "class", NULL)
  invisible(nodes)
}

fix_codeblocks <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  code <- xml2::xml_find_all(nodes, ".//div[starts-with(@class, 'sourceCode')]")
  xml2::xml_set_attr(code, "class", "codewrapper sourceCode")
  pre <- xml2::xml_children(code)
  type <- rev(trimws(sub("sourceCode", "", xml2::xml_attr(pre, "class"))))
  add_code_heading(pre, toupper(type))
  outputs <- xml2::xml_find_all(nodes, ".//pre[@class='output' or @class='warning' or @class='error']")
  if (length(outputs)) {
    xml2::xml_add_parent(outputs, "div", class = "codewrapper")
    class_headings <- rev(toupper(xml2::xml_attr(outputs, "class")))
    add_code_heading(outputs, class_headings)
  }
  invisible(nodes)
}

add_code_heading <- function(codes = NULL, labels = "OUTPUT") {
  if (length(codes) == 0) return(codes)
  xml2::xml_set_attr(codes, "tabindex", "0")
  heads <- xml2::xml_add_sibling(codes, "h3", labels, class = "code-label", 
    .where = "before")
  for (head in heads) {
    xml2::xml_add_child(head, "i", 
      "aria-hidden" = "true", "data-feather" = "chevron-left")
    xml2::xml_add_child(head, "i", 
      "aria-hidden" = "true", "data-feather" = "chevron-right")
  }
  invisible(codes)
}

fix_figures <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  figs <- xml2::xml_find_all(nodes, ".//img")
  caps <- xml2::xml_find_all(nodes, ".//p[@class='caption']")
  fig_element <- xml2::xml_parent(figs)
  xml2::xml_set_attr(figs, "class", "figure mx-auto d-block")
  xml2::xml_set_name(caps, "figcaption")
  xml2::xml_set_attr(caps, "class", NULL)
  xml2::xml_set_name(fig_element, "figure")
  xml2::xml_set_attr(fig_element, "class", NULL)
  invisible(nodes)
}

fix_callouts <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  callouts <- xml2::xml_find_all(nodes, ".//div[starts-with(@class, 'callout')]")
  h3 <- xml2::xml_find_all(callouts, "./div/h3")
  xml2::xml_set_attr(h3, "class", "callout-title")
  inner_div <- xml2::xml_parent(h3)
  xml2::xml_set_attr(inner_div, "class", "callout-inner")
  invisible(nodes)
}

use_learner <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  copy <- xml2::read_html(as.character(nodes))
  inst <- xml2::xml_find_all(copy, ".//div[contains(@class, 'instructor')]")
  xml2::xml_remove(inst)
  as.character(copy)
}

use_instructor <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  copy <- xml2::read_html(as.character(nodes))
  lnk <- xml2::xml_find_all(copy, ".//a[not(starts-with(@href, 'http'))]")
  img <- xml2::xml_find_all(copy, ".//img[not(starts-with(@src, 'http'))]")
  xml2::xml_set_attr(lnk, "href", fs::path("../", xml2::xml_attr(lnk, "href")))
  xml2::xml_set_attr(img, "src", fs::path("../", xml2::xml_attr(img, "src")))
  as.character(copy)
}
