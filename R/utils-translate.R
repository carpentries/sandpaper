these <- new.env(parent = emptyenv())
#' Show a list of languages known by {sandpaper}
#'
#' @return a character vector of language codes known by {sandpaper}
#'
#' @details The known languages are translations of menu and navigational
#' elements that exist in {sandpaper}. If these elements have not been
#' translated for a given language and you would like to add translations for
#' them, please consult `vignette("translations", package = "sandpaper")` for
#' details of how to do so in the source code for {sandpaper}.
#'
#' ## List of Known Languages:
#'
#' ```{r, echo = FALSE}
#' langs <- known_languages()
#' writeLines(paste("-", langs))
#' ```
#'
#' @export
#' @examples
#' known_languages()
known_languages <- function() {
  lang_files <- system.file("po", package = "sandpaper")
  as.character(c("en", fs::path_file(fs::dir_ls(lang_files, type = "dir"))))
}

is_known_language <- function(lang = NULL, warn = FALSE) {
  lang <- lang %||% "en"
  not_known <- strsplit(lang, "_")[[1]][1] %nin% known_languages()
  if (not_known && warn) {
    warn_no_language(lang)
  }
  return(!not_known)
}

# Translations for static lesson elements happens during the `build_site()`
# phase. The `set_language()` function is run. It should only ever be run
# inside of another function to ensure the scope is honoured.
set_language <- function(lang = NULL, scope = parent.frame()) {
  lang <- lang %||% "en"
  known <- is_known_language(lang, warn = TRUE)
  if (known) {
    withr::local_envvar(
      LANGUAGE = lang,
      .local_envir = scope
    )
  }
  add_varnish_translations()
}




# These are all the translations that occur in {varnish}
add_varnish_translations <- function() {
  to_translate <- these$translations$src
  menu_translations <- lapply(to_translate$varnish, tr_) 
  these$translations$varnish <- menu_translations

  learner_globals$set("translate", menu_translations)
  instructor_globals$set("translate", menu_translations)

  # computed translations are added before the pages are passed to varnish
  to_compute <- to_translate[names(to_translate) != "varnish"]
  shared <- c("Home", "KeyPoints", "LearnerProfiles")
  these$translations$computed <- c(
    lapply(to_translate, tr_),
    menu_translations[shared],
    # NOTE: this is NOT a typo: it is an alternate form of KeyPoints so that
    # the callout fixer can recognise it
    Keypoints = menu_translations[["KeyPoints"]]
  )
  fix_both_sidebars(learner_globals, instructor_globals)
}

# Apply translations to text assuming that the names of the translations
# matches the text
apply_translations <- function(txt, translations) {
  ntxt <- length(txt)
  ntranslations <- length(translations)
  # empty text or empty translations returns the text
  if (ntxt == 0L || ntranslations == 0L) {
    return(txt)
  }
  # when there are translations, apply them only to the matching elements of
  # the vector
  to_translate <- txt %in% names(translations)
  if (any(to_translate)) {
    ids <- txt[to_translate]
    txt[to_translate] <- translations[ids]
  }
  return(txt)
}

# generator of translations for code blocks.
get_codeblock_translations <- function() {
  needed <- c("OUTPUT", "ERROR", "WARNING")
  unlist(these$translations$computed[needed])
}

# generator for translations of callout blocks and accordions
get_callout_translations <- function() {
  needed <- c("Callout", "Challenge", "Prereq", "Checklist", "Discussion",
    "Testimonial", "Keypoints")
  unlist(these$translations$computed[needed])
}
get_accordion_translations <- function() {
  needed <- c("Show me the solution",
    "Give me a hint",
    "Show details",
    "Instructor Note"
  )
  unlist(these$translations$computed[needed])
}


# See the `fix_sidebar_translation()` comment. This takes the learner and
# instructor global data and fixes the titles of the  first element
# representing the home page.
fix_both_sidebars <- function(learner, instructor) {
  lside <- learner$get()[["sidebar"]]
  learn_summary <- these$translations$computed$SummaryAndSetup
  learner$set("sidebar", fix_sidebar_translation(lside, learn_summary))

  iside <- instructor$get()[["sidebar"]]
  instruct_summary <- these$translations$computed$SummaryAndSchedule
  instructor$set("sidebar", fix_sidebar_translation(lside, instruct_summary))
}

# The sidebar construction happens during the first parts of `build_lesson()`
# when `validate_lesson()` is called and the Lesson object is loaded.
#
# Because of this, it will always be in the local of the user, which is not
# necessarily the locale of the lesson. We should not necessarily impose the
# lesson locale on the user because the error messages from earlier build
# stages should be in the user's locale.
#
# This is all a really long-winded way to say that we need to set the
# translation here, where the translation variables are set.
#
# This function takes a sidebar list, a translation for either "summary and
# schedule" or "summary and setup" and applies the translation to the HTML for
# the first element
fix_sidebar_translation <- function(sidebar, translation) {
  first_item <- xml2::read_xml(sidebar[[1]])
  idx <- xml2::xml_find_first(first_item, ".//a")
  if (startsWith(xml2::xml_text(idx), "Summary")) {
    xml2::xml_set_text(idx, translation)
  } else {
    return(sidebar)
  }
  sidebar[[1]] <- as.character(first_item)
  return(sidebar)
}


# replace text string with a <(kirby template)> with link text
# replace_link("this string has a <(kirby template)>", "https://emojicombos.com/kirby")
replace_link <- function(txt, href) {
  replace_html(txt, open = paste0('<a href="', href, '">'), close = "</a>")
}

replace_html <- function(txt, open, close) {
  txt <- sub("<(", open, txt, fixed = TRUE)
  return(sub(")>", close, txt, fixed = TRUE))
}

#' Apply template items to translated strings
#'
#' @param the_data a list of global variables (either `learner_globals` or
#' `instructor_globals`) that also contains a "translate" element containing
#' a list of translated strings.
#'
#' @return the translated list with templated data filled out
#' @keywords internal
#' @details There are two kinds of templating we use:
#'
#'  1. variable templating indicated by `{key}` where `key` represents a
#'     variable that exists within the global data and is replaced.
#'  2. link templating indicated by `<(text to wrap)>` where we replace the
#'     `<()>` with a known URL or HTML markup. This allows the translators to
#'     translate text without having to worry about HTML markup.
#' @examples
#'
#' dat <- list(
#'   a = "a barn",
#'   b = "a bee",
#'   minutes = 5,
#'   translate = list(
#'      one = "a normal translated string (pretend it's translated from another language)",
#'      two = "a question: are you (A) {a}, (B) {b}",
#'      EstimatedTime = "Estimated time: {icons$clock} {minutes}",
#'      license = "Licensed under {license} by {authors}",
#'      ThisLessonCoC = "This lesson operates under our <(Code of Conduct)>"
#'   )
#' )
#' asNamespace("sandpaper")$fill_translation_vars(dat)
fill_translation_vars <- function(the_data) {
  # define icons that we will need to pre-fab insert for the template.
  icns <- c("clock", "edit")
  template_icns <- glue::glue(
    '<i aria-hidden="true" data-feather="{icns}"></i>'
  )

  # add our templating variables to the data list
  dat <- c(the_data,
    list(
       icons = setNames(as.list(template_icns), icns),
       template_authors = '<a href="https://carpentries.org/">The Carpentries</a>',
       authors = "the authors",
       license = the_data$license %||% "CC-BY 4.0",
       minutes = the_data$minutes %||% NULL,
       updated = the_data$updated %||% NULL
    )
  )
  # variables that have known fixed URLs can simply have them added in.
  dat$license <- glue::glue('<a href="LICENSE.html">{dat$license}</a>')
  translated <- the_data[["translate"]]

  # all translated items need to have variables replaced and the URL templates
  # filled out.
  for (key in names(translated)) {
    the_string <- translated[[key]]
    is_templated <- grepl("[{][A-z_$.]+?[}]", the_string)
    if (is_templated) {
      # if the string has a template variable {key}, it should be replaced
      # via {glue}.
      the_string <- glue::glue_data(dat, the_string)
    }
    string_exists <- length(the_string) > 0L
    has_url_template <- string_exists && grepl("<(", the_string, fixed = TRUE)
    if (has_url_template) {
      # In this space, we need to replace links present in the URL template
      # with their URLs
      # (e.g. going from `<(hello)>` to `<a href="hello.html">hello</a>`)
      the_string <- switch(key,
        ThisLessonCoC = replace_link(the_string,
          href = "CODE_OF_CONDUCT.html"
        ),
        TemplateLicense = replace_link(the_string,
          href = "https://creativecommons.org/licenses/by-sa/4.0/"
        ),
        SpanToTop = replace_html(the_string,
          open = '<span class="d-none d-sm-none d-md-none d-lg-none d-xl-block">',
          close = '</span>'
        ),
        the_string
      )
    }
    translated[[key]] <- the_string
  }
  return(translated)
}
