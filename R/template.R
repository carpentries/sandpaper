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
copy_template <- function(template, path, name) {
  template <- eval(parse(text = paste0("template_", template, "()")))
  fs::file_copy(template, new_path = fs::path(path, name))
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




