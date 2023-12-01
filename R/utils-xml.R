fix_nodes <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  translate_overview(nodes)
  fix_headings(nodes)
  fix_callouts(nodes)
  fix_codeblocks(nodes)
  fix_figures(nodes)
  fix_setup_link(nodes)
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
  id <- xml2::xml_attr(sections, "id")
  add_anchors(h2, xml2::xml_attr(sections, "id"))
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
  imgs <- xml2::xml_find_all(nodes, ".//img")
  add_class(imgs, "figure")
  # make sure to grab the figures. These could be obvious
  fig_XPath <- ".//div[@class='figure' or @class='float']/img"
  # or they could be bare HTML image tags that were never converted
  lone_img_XPath <- ".//p[count(descendant::*)=1 and count(text())=0]/img"
  XPath <- glue::glue("{fig_XPath} | {lone_img_XPath}")
  figs <- xml2::xml_find_all(nodes, XPath)
  caps <- xml2::xml_find_all(nodes, ".//p[@class='caption']")
  fig_element <- xml2::xml_parent(figs)
  add_class(figs, "mx-auto d-block")
  xml2::xml_set_name(caps, "figcaption")
  xml2::xml_set_attr(caps, "class", NULL)
  xml2::xml_set_name(fig_element, "figure")
  xml2::xml_set_attr(fig_element, "class", NULL)
  invisible(nodes)
}

add_class <- function(nodes, new) {
  classes <- xml2::xml_attr(nodes, "class")
  classes <- ifelse(is.na(classes), "", classes)
  classes <- paste(classes, new)
  xml2::xml_set_attr(nodes, "class", trimws(classes))
}

add_anchors <- function(nodes, ids) {
  anchor <- paste0(
    "<a class='anchor' aria-label='", tr_("anchor"), "' href='#", ids, "'></a>"
  )
  for (i in seq_along(nodes)) {
    heading <- nodes[[i]]
    if (length(xml2::xml_contents(heading)) == 0) {
      # skip empty headings
      next
    }
    # Insert anchor in first element of header
    xml2::xml_add_child(heading, xml2::read_xml(anchor[[i]]))
  }
}

# translate the overview cards, which are defined in
# inst/rmarkdown/lua/lesson.lua
translate_overview <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  card <- xml2::xml_find_first(nodes, ".//div[@class='overview card']")
  if (length(card) == 0) {
    return(nodes)
  }
  overview <- xml2::xml_find_first(card, "./h2[@class='card-header']")
  qpath <- ".//div[starts-with(@class, 'inner')]/h3[@class='card-title'][text()='Questions']"
  opath <- ".//div[starts-with(@class, 'inner')]/h3[@class='card-title'][text()='Objectives']"
  questions <- xml2::xml_find_first(card, qpath)
  objectives <- xml2::xml_find_first(card, opath)

  xml2::xml_set_text(questions, tr_("Questions"))
  xml2::xml_set_text(objectives, tr_("Objectives"))
  xml2::xml_set_text(overview, tr_("Overview"))
  invisible(nodes)
}

fix_callouts <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  callouts <- xml2::xml_find_all(nodes, ".//div[starts-with(@class, 'callout ')]")
  h3 <- xml2::xml_find_all(callouts, "./div/h3")
  lapply(h3, translate_callout_heading)
  xml2::xml_set_attr(h3, "class", "callout-title")
  inner_div <- xml2::xml_parent(h3)
  # remove the "section level3 callout-title" attrs
  xml2::xml_set_attr(inner_div, "class", "callout-inner")
  # Get the heading IDS (because we use section headings, the IDs are anchored
  # to the section div and not the heading element)
  # <div class="section level3 callout-title callout-inner">
  #   <h3>Heading for this callout</h3>
  # </div>
  ids <- xml2::xml_attr(inner_div, "id")
  # get the callout ID in the cases where they are missing
  replacements <- xml2::xml_attr(callouts, "id")
  ids <- ifelse(is.na(ids), replacements, ids)
  # add the anchors and then set the attributes in the correct places.
  add_anchors(h3, ids)
  xml2::xml_set_attr(h3, "id", NULL)
  # we replace the callout ID with the correct ID
  xml2::xml_set_attr(callouts, "id", ids)
  invisible(nodes)
}

# translate callouts that have generic headings.
#
# If a callout does not have a heading, it has callout class converted to a 
# title case heading. This is most common with key points. This applies the
# appropriate translations based on the language of the lesson (including
# English)
translate_callout_heading <- function(heading) {
  txt <- xml2::xml_text(heading)
  known <- c(
    "Callout",
    "Challenge",
    "Prereq",
    "Checklist",
    "Solution",
    "Hint",
    "Spoiler",
    "Discussion",
    "Testimonial",
    "Keypoints",
    "Instructor"
  )
  if (txt %in% known) {
    translated <- switch(txt,
      Callout     = tr_("Callout"),
      Challenge   = tr_("Challenge"),
      Prereq      = tr_("Prerequisite"),
      Checklist   = tr_("Checklist"),
      Solution    = tr_("Solution"),
      Hint        = tr_("Hint"),
      Spoiler     = tr_("Spoiler"),
      Discussion  = tr_("Discussion"),
      Testimonial = tr_("Testimonial"),
      Keypoints   = tr_("Key Points"),
      Instructor  = tr_("Instructor Note"),
      txt
    )
    xml2::xml_set_text(heading, translated)
  }
  return(invisible(heading))
}

fix_setup_link <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  links <- xml2::xml_find_all(nodes, ".//a")
  hrefs <- xml2::url_parse(xml2::xml_attr(links, "href"))
  setup_links <- hrefs$scheme == "" &
    hrefs$server == "" &
    hrefs$path == "setup.html"
  fragment <- hrefs$fragment[setup_links]
  fragment <- ifelse(fragment == "", "setup", fragment)
  replacement <- paste0("index.html#", fragment)
  xml2::xml_set_attr(links[setup_links], "href", replacement)
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
  # find all local links and transform non-html and nested links ---------
  no_external <- "not(contains(@href, '://'))"
  no_anchors  <- "not(starts-with(@href, '#'))"
  no_mail     <- "not(starts-with(@href, 'mailto:'))"
  predicate <- paste(c(no_external, no_anchors, no_mail), collapse = " and ")
  XPath <- sprintf(".//a[@href][%s]", predicate)
  lnk <- xml2::xml_find_all(copy, XPath)
  lnk_hrefs <- xml2::xml_attr(lnk, "href")
  lnk_paths <- xml2::url_parse(lnk_hrefs)$path
  # links without HTML extension
  not_html <- !fs::path_ext(lnk_paths) %in% c("html", "")
  # links that are not in the root directory (e.g. files/a.html, but not ./a.html)
  is_nested <- lengths(strsplit(sub("^[.][/]", "", lnk_paths), "/")) > 1
  is_above <- not_html | is_nested
  lnk_hrefs[is_above] <- fs::path("../", lnk_hrefs[is_above])
  xml2::xml_set_attr(lnk, "href", lnk_hrefs)
  # find all images and refer back to source
  img <- xml2::xml_find_all(copy, ".//img[not(starts-with(@src, 'http'))]")
  xml2::xml_set_attr(img, "src", fs::path("../", xml2::xml_attr(img, "src")))
  as.character(copy)
}
