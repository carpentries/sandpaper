fix_nodes <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  translate_overview(nodes)
  fix_headings(nodes)
  fix_accordions(nodes)
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

#' add codewrapper class and apply code heading to all code blocks
#'
#' The syntax highlighte4d code blocks that come out of pandoc have this
#' structure (where `lang` is the language of the code block):
#'
#' ```html
#' <div class="sourceCode" id="cb1">
#'   <pre class="sourceCode lang">
#'     <code class="sourceCode lang">
#'     ...
#'     </code>
#'   </pre>
#' </div>
#' ```
#'
#' In The Workbench, we want to have this structure:
#'
#' ```html
#' <div class="codewrapper sourceCode" id="cb1">
#'   <h3 class="code-label">
#'    LANG
#'    <i aria-hidden=true data-feather="chevron-left"></i>
#'    <i aria-hidden=true data-feather="chevron-right"></i>
#'   </h3>
#'   <pre class="sourceCode lang" tabindex="0">
#'     <code class="sourceCode lang">
#'     ...
#'     </code>
#'   </pre>
#' </div>
#' ```
#'
#' This allows us to display the language of the code block in the lesson,
#' which can be helpful when the lesson switches between BASH and another
#' language.
#'
#' @param nodes HTML nodes
#' @return the modified nodes
#'
#' @noRd
fix_codeblocks <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  code <- xml2::xml_find_all(nodes, ".//div[starts-with(@class, 'sourceCode')]")
  xml2::xml_set_attr(code, "class", "codewrapper sourceCode")
  pre <- xml2::xml_children(code)
  # pre-compile these during the transformation so we only have to do it
  # once per document
  translations <- get_codeblock_translations()
  # Extract the language, transform to all caps, and reverse the order.
  # We need to reverse the order so that we can add
  type <- toupper(trimws(sub("sourceCode", "", xml2::xml_attr(pre, "class"))))
  add_code_heading(pre, apply_translations(type, translations))
  outputs <- xml2::xml_find_all(nodes,
    ".//pre[@class='output' or @class='warning' or @class='error']")
  if (length(outputs)) {
    xml2::xml_add_parent(outputs, "div", class = "codewrapper")
    class_headings <- toupper(trimws(xml2::xml_attr(outputs, "class")))
    add_code_heading(outputs, apply_translations(class_headings, translations))
  }
  invisible(nodes)
}

add_code_heading <- function(codes = NULL, labels = "OUTPUT") {
  if (length(codes) == 0) return(codes)
  xml2::xml_set_attr(codes, "tabindex", "0")
  # NOTE: xml_add_sibling adds the siblings from bottom to top, so these labels
  # need to be in reverse. It's weird.
  heads <- xml2::xml_add_sibling(codes, "h3", rev(labels),
    class = "code-label", .where = "before"
  )
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
  tranchor <- tr_computed("Anchor")
  anchor <- paste0(
    "<a class='anchor' aria-label='", tranchor, "' href='#", ids, "'></a>"
  )

  for (i in seq_along(nodes)) {
    heading <- nodes[[i]]

    if (length(xml2::xml_contents(heading)) == 0) {
      # skip empty headings
      next
    }

    # Insert anchor in first element of header
    xml2::xml_add_child(heading, xml2::read_xml(anchor[[i]]))

    # fix for pkgdown 2.1.0 now adding in anchors for <section> tags
    # rename our workbench translated sections <workbench-section>
    # this would require a lot more downstream work
    # sections <- xml2::xml_parent(heading)
    # xml2::xml_set_name(sections, "workbench-section")
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
  translated <- tr_computed()

  xml2::xml_set_text(questions, translated[["Questions"]])
  xml2::xml_set_text(objectives, translated[["Objectives"]])
  xml2::xml_set_text(overview, translated[["Overview"]])
  invisible(nodes)
}

# translate contents of an XML node list
# @param nodes an xml node or xml nodelist
# @param translations a named vector of translated strings whose names are the
#   strings in English
xml_text_translate <- function(nodes, translations) {
  txt <- xml2::xml_text(nodes, trim = FALSE)
  xml2::xml_set_text(nodes, apply_translations(txt, translations))
  return(invisible(nodes))
}

fix_accordions <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  accordions <- xml2::xml_find_all(nodes,
    ".//div[starts-with(@class, 'accordion ')]"
  )
  # NOTE: we need to include `text()` in the call here because of the presence
  # of the decorative blocks inside the accordion headings.
  # solution and hint are h4
  # instructor and spoiler are h3
  headings <- xml2::xml_find_all(accordions,
    "./div/button/h3/text() | ./div/button/h4/text()"
  )
  translations <- get_accordion_translations()
  xml_text_translate(headings, translations)
  # at this point, we would fix headings, but we do not actually have a way to
  # consistently do this, so it remains as an exercise for the future.
  return(invisible(nodes))
}

fix_callouts <- function(nodes = NULL) {
  if (length(nodes) == 0) return(nodes)
  # fix for https://github.com/carpentries/sandpaper/issues/470
  callouts <- xml2::xml_find_all(nodes, ".//div[starts-with(@class, 'callout ')] | .//div[@class='callout']")

  # https://github.com/carpentries/sandpaper/issues/556
  translations <- get_callout_translations()

  # process only h3 titles with no child tags for translation
  # https://github.com/carpentries/sandpaper/issues/562
  h3_translate <- xml2::xml_find_all(callouts, "./div/h3[not(*)]")
  h3_text <- xml2::xml_find_all(h3_translate, ".//text()")
  xml_text_translate(h3_text, translations)

  h3 <- xml2::xml_find_all(callouts, "./div/h3")
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
