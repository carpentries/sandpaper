build_keypoints <- function(pkg, pages = NULL, quiet = FALSE) {
  build_extra_page(pkg = pkg, 
    pages = pages, 
    title = "Key Points", 
    slug = "key-points", 
    aggregate = "/div[starts-with(@id, 'keypoints')]/div[@class='callout-inner']/div[@class='callout-content']/*", 
    prefix = FALSE, 
    quiet = quiet)
}

provision_keypoints <- function(pkg, quiet) {
    provision_extra_page(pkg, title = "Key Points", slug = "key-points.html", 
        quiet)
}

make_keypoints_section <- function(name, contents, parent) {
    title <- names(name)
    uri <- sub("^keypoints-", "", name)
    new_section <- "<section id='{name}'>
     <h2 class='section-heading'><a href='{uri}.html'>{title}</a></h2>
     <hr class='half-width'/>
     </section>"
    section <- xml2::read_xml(glue::glue(new_section))
    for (element in contents) {
        xml2::xml_add_child(section, element)
    }
    xml2::xml_add_child(parent, section)
}
