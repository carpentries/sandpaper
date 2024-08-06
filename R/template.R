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

#' copy a sandpaper template file to a path with data
#'
#' @param template the base of a valid template function (e.g. "episode" for 
#'   [template_episode()])
#' @param path the folder in which to write the file. Defaults to `NULL`, which 
#'   will return the filled template as a character vector
#' @param name the name of the file. Defaults to `NULL`
#' @param values the values to fill in the template (if any). Consult the
#'   files in the `templates/` folder of your sandpaper installation for details.
#' @return a character vector if `path` or `name` is `NULL`, otherwise, this is
#'   used for its side effect of creating a file.
#' @keywords internal
copy_template <- function(template, path = NULL, name = NULL, values = NULL) {
  template <- eval(parse(text = paste0("template_", template, "()")))
  out <- if (is.null(path)) NULL else fs::path(path, name)
  if (!is.null(values)) {
    temp <- readLines(template, encoding = "UTF-8")
    res  <- whisker::whisker.render(template = temp, data = values)
    if (length(out)) writeLines(res, out) else return(res)
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
#' @keywords internal
#' @return a character string with the path to the template within the
#'   `{sandpaper}` repo. 
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
template_citation <- generate_template_function("citation")

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

#' @rdname template
#' @export
template_placeholder <- generate_template_function("placeholder")

#' @rdname template
#' @export
template_pr_diff <- generate_template_function("pr_diff")

#' @rdname template
#' @export
template_sidebar_item <- generate_template_function("sidebar_item")

#' @rdname template
#' @export
template_metadata <- generate_template_function("metadata")
