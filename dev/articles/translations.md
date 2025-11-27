# Translating The Workbench

## Introduction

The philosophy of The Carpentries Workbench is one of separation between
lesson content and the tooling needed to transform that content into a
website. It is possible to write a lesson in any human language that has
a syllabary which can be represented on a computer. The only catch is:
by default the language of the *website template*—all the navigational
elements of the website—is English, so authors need to tell The
Workbench what language the website template should use.

To write a lesson in a specific language, the lesson author should add
`lang: 'xx'` to the `config.yaml` file where `xx` represents the
[language
code](https://www.gnu.org/software/gettext/manual/html_node/Usual-Language-Codes.html)
that matches the language of the lesson content. This defaults to
`"en"`, but can be any language code (e.g. “ja” specifying Japanese) or
combination language code and [country
code](https://www.gnu.org/software/gettext/manual/html_node/Country-Codes.html)
(e.g. “pt_BR” specifies Pourtugese used in Brazil). For more information
on how this is used, see [the Locale Names section of the gettext
manual](https://www.gnu.org/software/gettext/manual/html_node/Locale-Names.html).
If there is country-specific variation for a language that needs to be
added, it is not necessary to re-translate everything that is identical
in the original language file—you only need to translate what is
different.

Setting the `lang:` keyword will allow the lesson navigational elements
of the website template to be presented in the same language as the
lesson content *if the language has been added to {sandpaper}*. If not,
the menu items will appear in English.

This vignette is of interest to those who wish to update translations or
add new translations. In this vignette I will provide resources for
updating and adding new languages, the process by which translation
happens, and I will outline special syntax used in {sandpaper}.

## Resources

### Recommended Tools

To provide translations as a non-maintainer, you need only a text editor
to add translations to the strings present in the `.po` translation
files (see more about these files in the [Translating in {sandpaper}
section](#translating-in-sandpaper).

If you would like to compile and test these translations locally, you
will need the [{potools}
package](https://michaelchirico.github.io/potools/), which requires the
[GNU gettext system](https://www.gnu.org/software/gettext/). As
mentioned in the [{potools} installation
documentation](https://michaelchirico.github.io/potools/#installation),
if you are on macOS, you will likely need to use `brew` to install
`gettext` with `brew install gettext`, otherwise, it is bundled with
RTools (needed for package development on Windows) and it is present on
most Linux distributions.

### Documentation

The documentation for the {potools} package is a wonderful resource. Use
[`vignette("translators", package = "potools")`](https://michaelchirico.github.io/potools/articles/translators.html)
to read details about what to consider when translating text in a
package. Another really good resource is [a blog post by Maëlle
Salmon](https://masalmon.eu/2023/10/06/potools-mwe/) which gives a
minimum working example of translating package messages using {potools}.

If you are interested in translating *lesson content*, please consult
Joel Nitta’s [Carpentries translation
guide](https://hackmd.io/@joelnitta/SkCSC6ZNT#Guide-for-translators-l10n).

You can use tools such as Joel Nitta’s
[{dovetail}](https://github.com/joelnitta/dovetail#readme) for providing
a method for translators to track and deploy translations of Carpentries
lessons. You can also use rOpenSci’s
[{babeldown}](https://docs.ropensci.org/babeldown/), which uses the
DeepL API for automated translation that translators can edit
afterwards.

## Translating in {sandpaper}

The translations from {sandpaper} are mostly shuffled off to {varnish},
where it has template variables written in mustache templating. These
variables define visible menu text such as “Key Points” and
screen-reader accessible text for buttons such as “close menu”.

There are 7 languages that are known to {sandpaper}:

- en
- de
- es
- fr
- it
- ja
- uk

If a language is not known to {sandpaper} and a lesson attempts to use
that language, it will default back to English (the source language).

### The source files of translations

When you translate in {sandpaper}, you will be working with `.po` files,
which are text files that live in [the po/
folder](https://github.com/carpentries/sandpaper/tree/HEAD/po) in the
source of this package. There is one `.po` file per language translated.
The syntax looks like this, where the first line shows the file where
the translation exists, the second line gives the message in English,
and the third line gives the translation:

``` po
#: build_404.R:57
msgid "Page not found"
msgstr "ページが見つかりません"
```

These files are recognised by [several well-established graphical user
interfaces](https://michaelchirico.github.io/potools/#alternative-software),
but since they are text files, you can edit them in any text editor or
on GitHub directly.

### How translations are processed in R

These po files are compiled into binary `.mo` files that are carried
with the built package on to the user’s computer. These files are used
by the R function
[`base::gettext()`](https://rdrr.io/r/base/gettext.html) to translate
messages in a specific context. The context for {sandpaper} is known as
`R-sandpaper`.

``` r
library("withr")
library("sandpaper")
known_languages()
#> [1] "en" "de" "es" "fr" "it" "ja" "uk"
with_language("ja", {
  enc2utf8(gettext("Page not found", domain = "R-sandpaper"))
})
#> [1] "Page not found"
with_language("en", {
  enc2utf8(gettext("Page not found", domain = "R-sandpaper"))
})
#> [1] "Page not found"
```

If a language does not exist, it will revert to English:

``` r
with_language("xx", {
  enc2utf8(gettext("Page not found", domain = "R-sandpaper"))
})
#> [1] "Page not found"
```

To make translation keys easier to detect, an internal convenience
function, `tr_()` has been defined, In addition, the source strings and
keys for the translations can be found from
[`tr_src()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md),
[`tr_varnish()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
and
[`tr_computed()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md),
so if you want to find the context for a given translation key, you can
find it by searching the source code for `tr_`.

### Special syntax for translators

Some content for translation requires variables or markup to be added
after translation.

Items in `{curly_braces}` are variables and should remain in English:

``` po
#: utils-translate.R:52
msgid "Estimated time: {icons$clock} {minutes} minutes"
msgstr "所要時間：{icons$clock} {minutes}分"
```

Words in `<(kirby quotes)>` will have HTML markup surrounding them and
should be translated:

    #: utils-translate.R:62
    msgid "This lesson is subject to the <(Code of Conduct)>"
    msgstr "このレッスンは<(行動規範)>の対象となります"

### Updates to translations

There may be times in the future where translations will need to be
updated because text changes or is added. When this happens, the
maintainer of {sandpaper} will run the following commands to extract the
new translation strings, update all languages, and recompile the `.mo`
files for the built package.

``` r
potools::po_extract()
potools::po_update()
potools::po_compile()
```

When the languages are updated, the translation utility will attempt to
make fuzzy matches or create new strings. For example, if we update the
“Page not found” translation to be title case, add punctuation and a
little whimsy to be `"Page? Not Found! -_-;"`, when you go to edit your
translation, you might see something like this:

``` po
#: build_404.R:57
#, fuzzy
#| msgid "Page not found"
msgid "Page? Not Found! -_-;"
msgstr "ページが見つかりません"
```

The old translation will be used until a translator updates it and runs
`potools::po_compile()` to update the `.mo` files.

When new strings for translations are added, the translation utility
does not assume to know anything about translation and the will appear
like so:

``` po
#: build_404.R:57
msgid "A new translation approaches!"
msgstr ""
```

If no translation is available for a given string, it will default to
the string itself:

``` r
with_language("ja", {
  enc2utf8(gettext("A new translation approaches!", domain = "R-sandpaper"))
})
#> [1] "A new translation approaches!"
```

## List of Translation Variables

There are 62 translations generated by
[`set_language()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
that correspond to the following variables in
[varnish](https://carpentries.github.io/varnish/):

| variable                           | string                                                                                                                              |
|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `translate.SkipToMain`             | `'Skip to main content'`                                                                                                            |
| `translate.iPreAlpha`              | `'Pre-Alpha'`                                                                                                                       |
| `translate.PreAlphaNote`           | `'This lesson is in the pre-alpha phase, which means that it is in early development, but has not yet been taught.'`                |
| `translate.AlphaNote`              | `'This lesson is in the alpha phase, which means that it has been taught once and lesson authors are iterating on feedback.'`       |
| `translate.iAlpha`                 | `'Alpha'`                                                                                                                           |
| `translate.BetaNote`               | `'This lesson is in the beta phase, which means that it is ready for teaching by instructors outside of the original author team.'` |
| `translate.iBeta`                  | `'Beta'`                                                                                                                            |
| `translate.PeerReview`             | `'This lesson has passed peer review.'`                                                                                             |
| `translate.InstructorView`         | `'Instructor View'`                                                                                                                 |
| `translate.LearnerView`            | `'Learner View'`                                                                                                                    |
| `translate.MainNavigation`         | `'Main Navigation'`                                                                                                                 |
| `translate.ToggleNavigation`       | `'Toggle Navigation'`                                                                                                               |
| `translate.ToggleDarkMode`         | `'Toggle theme (auto)'`                                                                                                             |
| `translate.Menu`                   | `'Menu'`                                                                                                                            |
| `translate.SearchButton`           | `'Search the All In One page'`                                                                                                      |
| `translate.Setup`                  | `'Setup'`                                                                                                                           |
| `translate.KeyPoints`              | `'Key Points'`                                                                                                                      |
| `translate.InstructorNotes`        | `'Instructor Notes'`                                                                                                                |
| `translate.Glossary`               | `'Glossary'`                                                                                                                        |
| `translate.LearnerProfiles`        | `'Learner Profiles'`                                                                                                                |
| `translate.More`                   | `'More'`                                                                                                                            |
| `translate.LessonProgress`         | `'Lesson Progress'`                                                                                                                 |
| `translate.CloseMenu`              | `'close menu'`                                                                                                                      |
| `translate.EPISODES`               | `'EPISODES'`                                                                                                                        |
| `translate.Home`                   | `'Home'`                                                                                                                            |
| `translate.HomePageNav`            | `'Home Page Navigation'`                                                                                                            |
| `translate.RESOURCES`              | `'RESOURCES'`                                                                                                                       |
| `translate.ExtractAllImages`       | `'Extract All Images'`                                                                                                              |
| `translate.AIO`                    | `'See all in one page'`                                                                                                             |
| `translate.DownloadHandout`        | `'Download Lesson Handout'`                                                                                                         |
| `translate.ExportSlides`           | `'Export Chapter Slides'`                                                                                                           |
| `translate.PreviousAndNext`        | `'Previous and Next Chapter'`                                                                                                       |
| `translate.Previous`               | `'Previous'`                                                                                                                        |
| `translate.EstimatedTime`          | `'Estimated time: {icons$clock} {minutes} minutes'`                                                                                 |
| `translate.Next`                   | `'Next'`                                                                                                                            |
| `translate.NextChapter`            | `'Next Chapter'`                                                                                                                    |
| `translate.LastUpdate`             | `'Last updated on {updated}'`                                                                                                       |
| `translate.EditThisPage`           | `'Edit this page'`                                                                                                                  |
| `translate.ExpandAllSolutions`     | `'Expand All Solutions'`                                                                                                            |
| `translate.SetupInstructions`      | `'Setup Instructions'`                                                                                                              |
| `translate.DownloadFiles`          | `'Download files required for the lesson'`                                                                                          |
| `translate.ActualScheduleNote`     | `'The actual schedule may vary slightly depending on the topics and exercises chosen by the instructor.'`                           |
| `translate.BackToTop`              | `'Back To Top'`                                                                                                                     |
| `translate.SpanToTop`              | `'<(Back)> To Top'`                                                                                                                 |
| `translate.ThisLessonCoC`          | `'This lesson is subject to the <(Code of Conduct)>'`                                                                               |
| `translate.CoC`                    | `'Code of Conduct'`                                                                                                                 |
| `translate.EditOnGH`               | `'Edit on GitHub'`                                                                                                                  |
| `translate.Contributing`           | `'Contributing'`                                                                                                                    |
| `translate.Source`                 | `'Source'`                                                                                                                          |
| `translate.Cite`                   | `'Cite'`                                                                                                                            |
| `translate.Contact`                | `'Contact'`                                                                                                                         |
| `translate.About`                  | `'About'`                                                                                                                           |
| `translate.MaterialsLicensedUnder` | `'Materials licensed under <({license})> by the authors'`                                                                           |
| `translate.TemplateLicense`        | `'Template licensed under <(CC-BY 4.0)> by {template_authors}'`                                                                     |
| `translate.Carpentries`            | `'The Carpentries'`                                                                                                                 |
| `translate.BuiltWith`              | `'Built with {sandpaper_link}, {pegboard_link}, and {varnish_link}'`                                                                |
| `translate.ExpandAllSolutions`     | `'Expand All Solutions'`                                                                                                            |
| `translate.CollapseAllSolutions`   | `'Collapse All Solutions'`                                                                                                          |
| `translate.Collapse`               | `'Collapse'`                                                                                                                        |
| `translate.Episodes`               | `'Episodes'`                                                                                                                        |
| `translate.GiveFeedback`           | `'Give Feedback'`                                                                                                                   |
| `translate.LearnMore`              | `'Learn More'`                                                                                                                      |

In addition, there are 28 translations that are inserted *before* they
get to [varnish](https://carpentries.github.io/varnish/):

| variable               | string                              |
|------------------------|-------------------------------------|
| `OUTPUT`               | `'OUTPUT'`                          |
| `WARNING`              | `'WARNING'`                         |
| `ERROR`                | `'ERROR'`                           |
| `Overview`             | `'Overview'`                        |
| `Questions`            | `'Questions'`                       |
| `Objectives`           | `'Objectives'`                      |
| `Callout`              | `'Callout'`                         |
| `Challenge`            | `'Challenge'`                       |
| `Prereq`               | `'Prerequisite'`                    |
| `Checklist`            | `'Checklist'`                       |
| `Discussion`           | `'Discussion'`                      |
| `Testimonial`          | `'Testimonial'`                     |
| `Caution`              | `'Caution'`                         |
| `Keypoints`            | `'Key Points'`                      |
| `Show me the solution` | `'Show me the solution'`            |
| `Give me a hint`       | `'Give me a hint'`                  |
| `Show details`         | `'Show details'`                    |
| `Instructor Note`      | `'Instructor Note'`                 |
| `SummaryAndSetup`      | `'Summary and Setup'`               |
| `SummaryAndSchedule`   | `'Summary and Schedule'`            |
| `AllInOneView`         | `'All in One View'`                 |
| `PageNotFound`         | `'Page not found'`                  |
| `CiteThisLesson`       | `'Acknowledgements and Citations'`  |
| `AllImages`            | `'All Images'`                      |
| `Anchor`               | `'anchor'`                          |
| `Figure`               | `'Figure {element}'`                |
| `ImageOf`              | `'Image {i} of {n}: {sQuote(txt)}'` |
| `Finish`               | `'Finish'`                          |
