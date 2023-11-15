#' Build the 404 page for a lesson
#'
#' @details
#'
#' During the lesson build process, a 404 page with absolute links back to the
#' source pages must be generated otherwise, subsequent attempts to escape the
#' 404 page will be futile.
#'
#' This function is intended to be run on a lesson website that has already
#' been built and is called for its side-effect of creating a 404 page.
#'
#'
#' @param pkg a list object generated from [pkgdown::as_pkgdown()]
#' @param quiet passed to [build_html()]. When `FALSE` (default), a message
#'   will be printed to the screen about the build progress. When `TRUE`, no
#'   messages are generated.
#' @return `TRUE` if the page was successfully generated
#' @seealso [build_site()] which calls this function and [build_html()], which
#'   this function calls.
#'
#' @keywords internal
build_404 <- function(pkg, quiet = FALSE) {
  page_globals <- setup_page_globals()
  calls <- sys.calls()
  # When the page is in production (e.g. built with one of the `ci_` functions,
  # then we need to set the absolute paths to the site
  is_prod <- in_production(calls)
  if (is_prod) {
    url  <- page_globals$metadata$get()$url
    page_globals$instructor$set(c("site", "root"), url)
    page_globals$learner$set(c("site", "root"), url)
  }

  fof <- fs::path_package("sandpaper", "templates", "404-template.txt")
  html <- xml2::read_html(render_html(fof))
  if (is_prod) {
    # make sure index links back to the original root
    lnk <- xml2::xml_find_first(html, ".//a[@href='index.html']")
    xml2::xml_set_attr(lnk, "href", url)
    # update navigation so that we have full URL
    nav <- page_globals$learner$get()[c("sidebar", "more", "resources")]
    for (item in names(nav)) {
      # replace the relative index with
      new <- fix_sidebar_href(nav[[item]], server = url)
      if (length(nav[[item]]) == 1L) {
        new <- paste(new, collapse = "")
      }
      page_globals$learner$set(item, new)
      page_globals$instructor$set(item, new)
    }
  }
  fix_nodes(html)

  this_dat <- list(
    this_page = "404.html",
    body = html,
    pagetitle = "Page not found"
  )
  page_globals$instructor$update(this_dat)
  page_globals$learner$update(this_dat)
  page_globals$metadata$update(this_dat)

  build_html(template = "extra", pkg = pkg, nodes = html,
    global_data = page_globals, path_md = "404.html", quiet = quiet)
}
