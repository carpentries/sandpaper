#' @rdname build_agg
build_images <- function(pkg, pages = NULL, quiet = FALSE) {
  build_agg_page(pkg = pkg, 
    pages = pages, 
    title = "All Images", 
    slug = "images", 
    aggregate = "/figure", 
    prefix = FALSE, 
    quiet = quiet)
}

make_images_section <- function(name, contents, parent) {
  title <- names(name)
  uri <- sub("^images-", "", name)
  new_section <- "<section id='{name}'>
  <h2 class='section-heading'><a href='{uri}.html'>{title}</a></h2>
  <hr class='half-width'/>
  </section>"
  section <- xml2::read_xml(glue::glue(new_section))

  for (element in seq_along(contents)) {
    content <- contents[[element]]
    alt     <- xml2::xml_text(xml2::xml_find_all(content, "./img/@alt"))
    n <- length(alt)
    xml2::xml_add_child(section, "h3", glue::glue("Figure {element}"), 
      id = glue::glue("{name}-figure-{element}"))
    for (i in seq_along(alt)) {
      txt <- alt[[i]]
      if (length(txt) == 0) {
        txt <- "[no alt-text]"
      }
      if (txt == "") {
        txt <- "[decorative]"
      }
      desc <- glue::glue("Image {i} of {n}: {sQuote(txt)}")
      xml2::xml_add_child(section, "p", 'aria-hidden'="true", desc)
    }
    xml2::xml_add_child(section, contents[[element]])
    xml2::xml_add_child(section, "hr")
  }
  xml2::xml_add_child(parent, section)
}
