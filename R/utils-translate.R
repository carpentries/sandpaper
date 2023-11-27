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
    keypoints = tr_("Key Points"),
    see_aio = tr_("See all in one page")
    SkipMain = _tr('Skip to main content'),
    Previs = _tr('Previous'),
    Next = _tr('Next'),
    Back = _tr('Back'),
    Home = _tr('Home'),
    Menu = _tr('Menu'),
    More = _tr('More'),
    Edtthp = _tr('Edit this page'),
    Estim = _tr('Estimated time'),
    minutes = _tr('minutes'),
    ExprCS = _tr('Export Chapter Slides'),
    LrnrVw = _tr('Learner View'),
    InstrV = _tr('Instructor View'),
    Setup = _tr('Setup'),
    InstrN = _tr('Instructor Notes'),
    ExtrAI = _tr('Extract All Images'),
    Glssry = _tr('Glossary'),
    LrnrPr = _tr('Learner Profiles'),
    EPISOD = _tr('EPISODES'),
    RESOUR = _tr('RESOURCES'),
    DwnlLH = _tr('Download Lesson Handout')
    ExpnAS = _tr('Expand All Solutions'),
    StpIns = _tr('Setup Instructions'),
    Dfrftl = _tr('Download files required for the lesson'),
    actual_sched = _tr('The actual schedule may vary slightly depending on the topics and exercises chosen by the instructor.'),
    ThisLessonCoC = _tr('This lesson is subject to the Code of Conduct'),
    CoC = _tr('Code of Conduct'),
    EoGH = _tr('Edit on GitHub'),
    Contributing = _tr('Contributing'),
    Source = _tr('Source'),
    Cite = _tr('Cite'),
    Contct = _tr('Contact'),
    About = _tr('About'),
    MaterialsLicencedUnder = _tr('Materials licensed under'),
    byAuthors = _tr('by the authors'),
    byCarpentries = _tr('by The Carpentries'),
    CC4 = _tr('Template licensed under CC-BY 4.0'),
    ThCrpn = _tr('The Carpentries'),
    Bwspav = _tr('Built with'),
    PreAlphaNote = _tr('This lesson is in the pre-alpha phase, which means that it is in early development, but has not yet been taught.'),
    AlphaNote = _tr('This lesson is in the alpha phase, which means that it has been taught once and lesson authors are iterating on feedback.'),
    BetaNote = _tr('This lesson is in the beta phase, which means that it is ready for teaching by instructors outside of the original author team.'),
    GvFdbc = _tr('Give Feedback'),
    LernMr = _tr('Learn More'),
    English = _tr('English (US)'),
    French = _tr('French'),
  )
  learner_globals$set("translate", menu_translations)
  instructor_globals$set("translate", menu_translations)
}
