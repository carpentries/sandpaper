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
  not_known <- lang %nin% known_languages()
  if (not_known && warn) {
    warn_no_language(lang)
  }
  return(!not_known)
}

# Translations for static lesson elements happens during the `build_site()`
# phase. The `local_envvar_pkgdown()` function is run. It should only
# ever be run inside of another function to ensure the scope is honoured.
local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  lang <- pkg$meta$template$params$lang %||% "en"
  is_known_language(lang, warn = TRUE)
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = lang,
    .local_envir = scope
  )
  add_varnish_translations()
}




# These are all the translations that occur in {varnish}
add_varnish_translations <- function() {
  menu_translations <- list(
    # header.html -------------------------------------------------------------
    SkipToMain = tr_('Skip to main content'),# alt text
    iPreAlpha = tr_('Pre-Alpha'),
    PreAlphaNote = tr_('This lesson is in the pre-alpha phase, which means that it is in early development, but has not yet been taught.'),
    AlphaNote = tr_('This lesson is in the alpha phase, which means that it has been taught once and lesson authors are iterating on feedback.'),
    iAlpha = tr_('Alpha'),
    BetaNote = tr_('This lesson is in the beta phase, which means that it is ready for teaching by instructors outside of the original author team.'),
    iBeta = tr_('Beta'),
    PeerReview = tr_('This lesson has passed peer review.'),
    InstructorView = tr_('Instructor View'),   # navbar.html
    LearnerView = tr_('Learner View'),         # navbar.html
    MainNavigation = tr_('Main Navigation'), # alt text
    ToggleNavigation = tr_('Toggle Navigation'), # alt-text
    Menu = tr_('Menu'), # footer.html
    SearchButton = tr_('search button'),     # alt text
    Setup = tr_('Setup'),                      # navbar.html
    KeyPoints = tr_("Key Points"),             # navbar.html
    InstructorNotes = tr_('Instructor Notes'), # navbar.html
    Glossary = tr_('Glossary'),                # navbar.html
    LearnerProfiles = tr_('Learner Profiles'), # navbar.html
    More = tr_('More'),
    Search = tr_('Search'),
    LessonProgress = tr_('Lesson Progress'), # alt text

    # navbar.html -------------------------------------------------------------
    CloseMenu = tr_("close menu"), # alt text
    EPISODES = tr_('EPISODES'),
    Home = tr_('Home'), # content-chapter.html
    HomePageNav = tr_('Home Page Navigation'), # alt text
    RESOURCES = tr_('RESOURCES'),
    ExtractAllImages = tr_('Extract All Images'),
    AIO = tr_("See all in one page"),
    DownloadHandout = tr_('Download Lesson Handout'),
    ExportSlides = tr_('Export Chapter Slides'), # content-chapter.html

    # content-[thing].html ---------------------------------------------------
    PreviousAndNext = tr_('Previous and Next Chapter'), # alt text
    Previous = tr_('Previous'),
    EstimatedTime = tr_('Estimated time: {icons$clock} {minutes} minutes'),
    Next = tr_('Next'),
    NextChapter = tr_('Next Chapter'), # alt-text
    LastUpdate = tr_('Last updated on {updated}'),
    EditThisPage = tr_('Edit this page'),
    ExpandAllSolutions = tr_('Expand All Solutions'),

    # content-syllabus.html --------------------------------------------------
    SetupInstructions = tr_('Setup Instructions'),
    DownloadFiles = tr_('Download files required for the lesson'),
    ActualScheduleNote = tr_('The actual schedule may vary slightly depending on the topics and exercises chosen by the instructor.'),

    # footer.html ------------------------------------------------------------
    BackToTop = tr_('Back To Top'),
    SpanToTop = tr_('<(Back)> To Top'),
    ThisLessonCoC = tr_('This lesson is subject to the <(Code of Conduct)>'),
    CoC = tr_('Code of Conduct'),
    EditOnGH = tr_('Edit on GitHub'),
    Contributing = tr_('Contributing'),
    Source = tr_('Source'),
    Cite = tr_('Cite'),
    Contact = tr_('Contact'),
    About = tr_('About'),
    MaterialsLicensedUnder = tr_('Materials licensed under {license} by {authors}'),
    TemplateLicense = tr_('Template licensed under <(CC-BY 4.0)> by {template_authors}'),
    Carpentries = tr_('The Carpentries'),
    BuiltWith = tr_('Built with {sandpaper_link}, {pegboard_link}, and {varnish_link}'),

    # javascript --------------------------------------------------------------
    ExpandAllSolutions = tr_('Expand All Solutions'),
    CollapseAllSolutions = tr_('Collapse All Solutions'),
    Collapse = tr_('Collapse'),
    Episodes = tr_('Episodes'),

    # beta content not used anymore.
    GiveFeedback = tr_('Give Feedback'),
    LearnMore = tr_('Learn More')
  )
  learner_globals$set("translate", menu_translations)
  instructor_globals$set("translate", menu_translations)
  fix_both_sidebars(learner_globals, instructor_globals, menu_translations)
}

# Apply translations to text assuming that the names of the translations
# matches the text
apply_translations <- function(txt, translations) {
  ntxt <- length(txt)
  ntranslations <- length(translations)
  if (ntxt == 0L || ntranslations == 0L) {
    return(txt)
  }
  to_translate <- txt %in% names(translations)
  if (any(to_translate)) {
    ids <- txt[to_translate]
    txt[to_translate] <- translations[ids]
  }
  return(txt)
}

xml_text_translate <- function(nodes, translations) {
  txt <- xml2::xml_text(nodes, trim = TRUE)
  xml2::xml_set_text(nodes, apply_translations(txt, translations))
  return(invisible(nodes))
}

# generator of translations for code blocks.
get_codeblock_translations <- function() {
  c(
    OUTPUT = tr_("OUTPUT"),
    WARNING = tr_("WARNING"),
    ERROR = tr_("ERROR")
  )
}

get_accordion_translations <- function() {
  c(
    "Show me the solution" = tr_("Show me the solution"),
    "Give me a hint"       = tr_("Give me a hint"),
    "Show details"         = tr_("Show details"),
    "Instructor Note"      = tr_("Instructor Note")
  )
}


# See the `fix_sidebar_translation()` comment. This takes the learner and
# instructor global data and fixes the titles of the  first element
# representing the home page.
fix_both_sidebars <- function(learner, instructor, translations) {
  lside <- learner$get()[["sidebar"]]
  learn_summary <- tr_("Summary and Setup")
  learner$set("sidebar", fix_sidebar_translation(lside, learn_summary))

  iside <- instructor$get()[["sidebar"]]
  instruct_summary <- tr_("Summary and Schedule")
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
