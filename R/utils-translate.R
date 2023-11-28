# Translations for static lesson elements happens during the `build_site()`
# phase. The `local_envvar_pkgdown()` function is run. It should only 
# ever be run inside of another function to ensure the scope is honoured.
local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$meta$template$params$lang,
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
    SearchButton = tr_('search button'),     # alt text
    Setup = tr_('Setup'),                      # navbar.html
    KeyPoints = tr_("Key Points"),             # navbar.html
    InstructorNotes = tr_('Instructor Notes'), # navbar.html
    Glossary = tr_('Glossary'),                # navbar.html
    LearnerProfiles = tr_('Learner Profiles'), # navbar.html
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

    # content-chapter.html ----------------------------------------------------
    # TODO: continu to categorise this
    PreviousAndNext = tr_('Previous and Next Chapter'),
    Previous = tr_('Previous'),
    EstimatedTime = tr_('Estimated time: {% icons$clock %} {% minutes %} minutes'),
    Next = tr_('Next'),
    NextChapter = tr_('Next Chapter'),
    LastUpdate = tr_('Last updated on {% updated %}'),
    EditThisPage = tr_('Edit this page'),
    ExpandAllSolutions = tr_('Expand All Solutions'),

    Back = tr_('Back'),
    Menu = tr_('Menu'),
    More = tr_('More'),
    ThisLessonCoC = tr_('This lesson is subject to the Code of Conduct'),
    CoC = tr_('Code of Conduct'),
    EditOnGH = tr_('Edit on GitHub'),
    Contributing = tr_('Contributing'),
    Source = tr_('Source'),
    Cite = tr_('Cite'),
    Contact = tr_('Contact'),
    About = tr_('About'),
    SetupInstructions = tr_('Setup Instructions'),
    DownloadFiles = tr_('Download files required for the lesson'),
    ActualScheduleNote = tr_('The actual schedule may vary slightly depending on the topics and exercises chosen by the instructor.'),
    MaterialsLicencedUnder = tr_('Materials licensed under {% license %} by {% authors %}'),
    CC4 = tr_('Template licensed under CC-BY 4.0 by {% template_authors %}'),
    Carpentries = tr_('The Carpentries'),
    BuiltWith = tr_('Built with sandpaper{% sandpaper_version %}, pegboard{% pegboard_version %}, and varnish{% varnish_version %}'),
    GiveFeedback = tr_('Give Feedback'),
    LearnMore = tr_('Learn More')
  )
  learner_globals$set("translate", menu_translations)
  instructor_globals$set("translate", menu_translations)
}

fill_translation_vars <- function(the_data) {
  # define icons that we will need to pre-fab insert for the template. 
  icns <- c("clock", "edit")
  template_icons <- lapply(icns, function(i) {
    glue::glue('<i aria-hidden="true" data-feather="{i}"></i>')
  })

  # add our templating variables to the data list
  dat <- c(the_data, 
    list(
       icons = setNames(template_icons, icns),
       template_authors = "The Carpentries",
       authors = "the authors",
       license = "CC-BY 4.0",
       minutes = the_data$minutes %||% NULL,
       updated = the_data$updated %||% NULL
    )
  )
  # loop through the translation strings and replace all {% keys %}
  translated <- lapply(the_data[["translate"]],
    function(e, dat) {
      if (grepl("{%", e, fixed = TRUE)) {
        return(glue::glue_data(dat, e, .open = "{%", .close = "%}"))
      } else {
        return(e)
      }
    },
    dat = dat
  )
}
