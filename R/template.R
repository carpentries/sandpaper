# Unexported functions ---------------------------------------------------------
# function for generating the templates
#nocov start
generate_template_function <- function(f) {
  txt <- paste0("function() {
    system.file('templates', '", f, "-template.txt', package = 'sandpaper')
  }")
  eval(parse(text = txt))
}
#nocov end

# copy template on disk
copy_template <- function(template, path, name, values = NULL) {
  template <- eval(parse(text = paste0("template_", template, "()")))
  if (!is.null(values)) {
    temp <- readLines(template, encoding = "UTF-8")
    writeLines(whisker::whisker.render(temp, values), fs::path(path, name))
  } else {
    fs::file_copy(template, new_path = fs::path(path, name))
  }
}

# Exported ---------------------------------------------------------------------
#' Template files
#'
#' Use these files as templates for your own sandpaper lesson
#'
#' @rdname template
#' @export
#' @return a character string with the path to the template within the
#'   {sandpaper} repo. 
#' @examples
#'
#' cat(readLines(template_gitignore(), n = 6), sep = "\n")
template_gitignore <- generate_template_function("gitignore")

#' @rdname template
#' @export
template_episode <- generate_template_function("episode")

#' @rdname template
#' @export
template_links <- generate_template_function("links")

#' @rdname template
#' @export
template_config <- generate_template_function("config")

#' @rdname template
#' @export
template_conduct <- generate_template_function("conduct")

#' @rdname template
#' @export
template_index <- generate_template_function("index")

#' @rdname template
#' @export
template_license <- generate_template_function("license")

#' @rdname template
#' @export
template_contributing <- generate_template_function("contributing")

#' @rdname template
#' @export
template_setup <- generate_template_function("setup")

#' @rdname template
#' @export
template_pkgdown <- generate_template_function("pkgdown-yaml")




