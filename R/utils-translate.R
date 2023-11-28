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
    InstructorNotes = tr_('Instructor Notes'),
    ExtractAllImages = tr_('Extract All Images'),
    Glossary = tr_('Glossary'),
    LearnerProfiles = tr_('Learner Profiles'),
    see_aio = tr_("See all in one page"),
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
    Previs = tr_('Previous'),
    Next = tr_('Next'),
    Back = tr_('Back'),
    Home = tr_('Home'),
    Menu = tr_('Menu'),
    More = tr_('More'),
    Edtthp = tr_('Edit this page'),
    # the {% %} are variables that should _not_ be translated, but moved into
    # context of the translation.
    Estim = tr_('Estimated time: {% minutes %} minutes'),
    ExprCS = tr_('Export Chapter Slides'),
    LearnerView = tr_('Learner View'),
    InstructorView = tr_('Instructor View'),
    Setup = tr_('Setup'),
    EPISOD = tr_('EPISODES'),
    RESOUR = tr_('RESOURCES'),
    DwnlLH = tr_('Download Lesson Handout'),
    ExpnAS = tr_('Expand All Solutions'),
    StpIns = tr_('Setup Instructions'),
    Dfrftl = tr_('Download files required for the lesson'),
    actual_sched = tr_('The actual schedule may vary slightly depending on the topics and exercises chosen by the instructor.'),
    ThisLessonCoC = tr_('This lesson is subject to the Code of Conduct'),
    CoC = tr_('Code of Conduct'),
    EoGH = tr_('Edit on GitHub'),
    Contributing = tr_('Contributing'),
    Source = tr_('Source'),
    Cite = tr_('Cite'),
    Contct = tr_('Contact'),
    About = tr_('About'),
    MaterialsLicencedUnder = tr_('Materials licensed under'),
    byAuthors = tr_('by the authors'),
    byCarpentries = tr_('by The Carpentries'),
    CC4 = tr_('Template licensed under CC-BY 4.0'),
    ThCrpn = tr_('The Carpentries'),
    Bwspav = tr_('Built with'),
    GvFdbc = tr_('Give Feedback'),
    LernMr = tr_('Learn More'),
    English = tr_('English (US)'),
    French = tr_('French'),
    NULL
  )
  learner_globals$set("translate", menu_translations)
  instructor_globals$set("translate", menu_translations)
}
