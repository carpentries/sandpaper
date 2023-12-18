#nocov start
.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)
  delayedAssign("GITIGNORED", gitignore_items(), eval.env = ns, assign.env = ns)
  # Check for implicit {renv} consent. If the user has used it before, we should
  # use it in the {sandpaper} lesson, unless the user has explicitly told us not
  # to.
  op <- getOption("sandpaper.use_renv")
  if (is.null(op)) {
    try_use_renv()
  }
  # Create central list of elements to translate
  withr::with_language("en", {
    # These are keys and values known to varnish.
    varnish <- list(
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
      # navbar.html -----------------------------------------------------------
      CloseMenu = tr_("close menu"), # alt text
      EPISODES = tr_('EPISODES'),
      Home = tr_('Home'), # content-chapter.html
      HomePageNav = tr_('Home Page Navigation'), # alt text
      RESOURCES = tr_('RESOURCES'),
      ExtractAllImages = tr_('Extract All Images'),
      AIO = tr_("See all in one page"),
      DownloadHandout = tr_('Download Lesson Handout'),
      ExportSlides = tr_('Export Chapter Slides'), # content-chapter.html
      # content-[thing].html --------------------------------------------------
      PreviousAndNext = tr_('Previous and Next Chapter'), # alt text
      Previous = tr_('Previous'),
      EstimatedTime = tr_('Estimated time: {icons$clock} {minutes} minutes'),
      Next = tr_('Next'),
      NextChapter = tr_('Next Chapter'), # alt-text
      LastUpdate = tr_('Last updated on {updated}'),
      EditThisPage = tr_('Edit this page'),
      ExpandAllSolutions = tr_('Expand All Solutions'),
      # content-syllabus.html -------------------------------------------------
      SetupInstructions = tr_('Setup Instructions'),
      DownloadFiles = tr_('Download files required for the lesson'),
      ActualScheduleNote = tr_('The actual schedule may vary slightly depending on the topics and exercises chosen by the instructor.'),
      # footer.html -----------------------------------------------------------
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
      # javascript -----------------------------------------------------------
      ExpandAllSolutions = tr_('Expand All Solutions'),
      CollapseAllSolutions = tr_('Collapse All Solutions'),
      Collapse = tr_('Collapse'),
      Episodes = tr_('Episodes'),
      # beta content not used anymore.
      GiveFeedback = tr_('Give Feedback'),
      LearnMore = tr_('Learn More')
    )
    computed <- list(
      # These keys and values are used in {sandpaper} before they are
      # passed to {varnish}
      # Code blocks ----------------------------------------------------------
      OUTPUT = tr_("OUTPUT"),
      WARNING = tr_("WARNING"),
      ERROR = tr_("ERROR"),
      # Callouts -------------------------------------------------------------
      Overview    = tr_("Overview"),
      Questions   = tr_("Questions"),
      Objectives  = tr_("Objectives"),
      Overview    = tr_("Overview"),
      Callout     = tr_("Callout"),
      Challenge   = tr_("Challenge"),
      Prereq      = tr_("Prerequisite"),
      Checklist   = tr_("Checklist"),
      Discussion  = tr_("Discussion"),
      Testimonial = tr_("Testimonial"),
      Keypoints   = varnish$KeyPoints,
      # Accordions -----------------------------------------------------------
      "Show me the solution" = tr_("Show me the solution"),
      "Give me a hint"       = tr_("Give me a hint"),
      "Show details"         = tr_("Show details"),
      "Instructor Note"      = tr_("Instructor Note"),
      # Headings -------------------------------------------------------------
      SummaryAndSetup = tr_("Summary and Setup"),
      SummaryAndSchedule = tr_("Summary and Schedule"),
      AllInOneView = tr_("All in One View"),
      PageNotFound = tr_("Page not found"),
      AllImages = tr_("All Images"),
      # Misc -----------------------------------------------------------------
      Anchor = tr_("anchor"),
      Figure = tr_("Figure {element}"),
      ImageOf = tr_("Image {i} of {n}: {sQuote(txt)}"),
      Finish = tr_("Finish")
    )
    src = list(
      varnish = varnish,
      computed = computed
    )
    ns$these$translations <- list(
      src = src,
      varnish = varnish,
      computed = computed
    )
  })
  invisible()
}
#nocov end
