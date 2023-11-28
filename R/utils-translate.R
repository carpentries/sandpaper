local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$meta$template$params$lang,
    .local_envir = scope
  )
  add_varnish_translations()
}

add_varnish_translations <- function() {
  menu_translations <- list(
    KeyPoints = tr_("Key Points"),
    LearnerView = tr_('Learner View'),
    InstructorView = tr_('Instructor View'),
    InstructorNotes = tr_('Instructor Notes'),
    ExtractAllImages = tr_('Extract All Images'),
    Glossary = tr_('Glossary'),
    LearnerProfiles = tr_('Learner Profiles'),
    AIO = tr_("See all in one page"),
    SkipToMain = tr_('Skip to main content'),
    MainNavigation = tr_('Main Navigation'), # alt text
    LessonProgress = tr_('Lesson Progress'), # alt text
    Search = tr_('Search'),
    SearchButton = tr_('search button'), # alt text
    iPreAlpha = tr_('Pre-Alpha'),
    iAlpha = tr_('Alpha'),
    iBeta = tr_('Beta'),
    PreAlphaNote = tr_('This lesson is in the pre-alpha phase, which means that it is in early development, but has not yet been taught.'),
    AlphaNote = tr_('This lesson is in the alpha phase, which means that it has been taught once and lesson authors are iterating on feedback.'),
    BetaNote = tr_('This lesson is in the beta phase, which means that it is ready for teaching by instructors outside of the original author team.'),
    PeerReview = tr_('This lesson has passed peer review.'),
    Previous = tr_('Previous'),
    Next = tr_('Next'),
    Back = tr_('Back'),
    Home = tr_('Home'),
    Menu = tr_('Menu'),
    More = tr_('More'),
    ThisLessonCoC = tr_('This lesson is subject to the Code of Conduct'),
    CoC = tr_('Code of Conduct'),
    EditThisPage = tr_('Edit this page'),
    EditOnGH = tr_('Edit on GitHub'),
    Contributing = tr_('Contributing'),
    Source = tr_('Source'),
    Cite = tr_('Cite'),
    Contact = tr_('Contact'),
    About = tr_('About'),
    # the {% %} are variables that should _not_ be translated, but moved into
    # context of the translation.
    EstimatedTime = tr_('Estimated time: {% minutes %} minutes'),
    Setup = tr_('Setup'),
    EPISODES = tr_('EPISODES'),
    RESOURCES = tr_('RESOURCES'),
    ExpandAllSolutions = tr_('Expand All Solutions'),
    SetupInstructions = tr_('Setup Instructions'),
    DownloadHandout = tr_('Download Lesson Handout'),
    DownloadFiles = tr_('Download files required for the lesson'),
    ExportSlides = tr_('Export Chapter Slides'),
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
