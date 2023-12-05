#' @rdname build_agg
build_images <- function(pkg, pages = NULL, quiet = FALSE) {
  build_agg_page(
    pkg = pkg,
    pages = pages,
    title = tr_("All Images"),
    slug = "images",
    aggregate = "/img/..",
    prefix = FALSE,
    quiet = quiet
  )
}

#' Make a section of aggregated images
#'
#' This will insert xml figure nodes into the images page, printing the alt text
#' descriptions for users who are not using screen readers.
#'
#' @param name the name of the section, (may or may not be prefixed with `images-`)
#' @param contents an `xml_nodeset` of figure elements from [get_content()]
#' @param parent the parent div of the images page
#' @return the section that was added to the parent
#'
#' @keywords internal
#' @seealso [build_images()], [get_content()]
#' @examples
#' if (FALSE) {
#'   lsn <- "/path/to/lesson"
#'   pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))
#'
#'   # read in the All in One page and extract its content
#'   img <- get_content("images", content = "self::*", pkg = pkg)
#'   fig_content <- get_content("01-introduction", content = "/figure", pkg = pkg)
#'   make_images_section("01-introduction", contents = fig_content, parent = img)
#' }
make_images_section <- function(name, contents, parent) {
  title <- escape_ampersand(names(name))
  uri <- name
  new_section <- "<section id='{name}'>
  <h2 class='section-heading'><a href='{uri}.html'>{title}</a></h2>
  <hr class='half-width'/>
  </section>"
  section <- xml2::read_xml(glue::glue(new_section))

  for (element in seq_along(contents)) {
    content <- contents[[element]]
    alt <- xml2::xml_text(xml2::xml_find_all(content, "./img/@alt"))
    n <- length(alt)
    xml2::xml_add_child(section, "h3", glue::glue(tr_("Figure {element}")),
      id = glue::glue("{name}-figure-{element}")
    )
    for (i in seq_along(alt)) {
      txt <- alt[[i]]
      if (length(txt) == 0) {
        txt <- "[no alt-text]"
      }
      if (txt == "") {
        txt <- "[decorative]"
      }
      desc <- glue::glue(tr_("Image {i} of {n}: {sQuote(txt)}"))
      xml2::xml_add_child(section, "p", "aria-hidden" = "true", desc)
    }
    xml2::xml_add_child(section, contents[[element]])
    xml2::xml_add_child(section, "hr")
  }
  xml2::xml_add_child(parent, section)
}

