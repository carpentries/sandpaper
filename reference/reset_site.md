# Remove all files associated with the site

Use this if you want to rebuild your site from scratch.

## Usage

``` r
reset_site(path = ".")
```

## Arguments

- path:

  the path to the site

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ☐ Edit /tmp/Rtmp82VLs2/file1a9144e8ba/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ✔ First episode created in /tmp/Rtmp82VLs2/file1a9144e8ba/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> ✔ Lesson successfully created in /tmp/Rtmp82VLs2/file1a9144e8ba
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a9144e8ba...
#> /tmp/Rtmp82VLs2/file1a9144e8ba
build_lesson(tmp, preview = FALSE)
#> ── Initialising site ───────────────────────────────────────────────────
#> Copying <pkgdown>/BS3/assets/bootstrap-toc.css to bootstrap-toc.css
#> Copying <pkgdown>/BS3/assets/bootstrap-toc.js to bootstrap-toc.js
#> Copying <pkgdown>/BS3/assets/docsearch.css to docsearch.css
#> Copying <pkgdown>/BS3/assets/docsearch.js to docsearch.js
#> Copying <pkgdown>/BS3/assets/link.svg to link.svg
#> Copying <pkgdown>/BS3/assets/pkgdown.css to pkgdown.css
#> Copying <pkgdown>/BS3/assets/pkgdown.js to pkgdown.js
#> Copying <varnish>/pkgdown/assets/android-chrome-192x192.png to
#> android-chrome-192x192.png
#> Copying <varnish>/pkgdown/assets/android-chrome-512x512.png to
#> android-chrome-512x512.png
#> Copying <varnish>/pkgdown/assets/apple-touch-icon.png to
#> apple-touch-icon.png
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.eot to
#> assets/fonts/Mulish-Black.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.svg to
#> assets/fonts/Mulish-Black.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.ttf to
#> assets/fonts/Mulish-Black.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.woff to
#> assets/fonts/Mulish-Black.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.woff2 to
#> assets/fonts/Mulish-Black.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.eot to
#> assets/fonts/Mulish-BlackItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.svg to
#> assets/fonts/Mulish-BlackItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.ttf to
#> assets/fonts/Mulish-BlackItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.woff
#> to assets/fonts/Mulish-BlackItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.woff2
#> to assets/fonts/Mulish-BlackItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.eot to
#> assets/fonts/Mulish-Bold.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.svg to
#> assets/fonts/Mulish-Bold.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.ttf to
#> assets/fonts/Mulish-Bold.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.woff to
#> assets/fonts/Mulish-Bold.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.woff2 to
#> assets/fonts/Mulish-Bold.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.eot to
#> assets/fonts/Mulish-BoldItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.svg to
#> assets/fonts/Mulish-BoldItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.ttf to
#> assets/fonts/Mulish-BoldItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.woff to
#> assets/fonts/Mulish-BoldItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.woff2
#> to assets/fonts/Mulish-BoldItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.eot to
#> assets/fonts/Mulish-ExtraBold.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.svg to
#> assets/fonts/Mulish-ExtraBold.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.ttf to
#> assets/fonts/Mulish-ExtraBold.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.woff to
#> assets/fonts/Mulish-ExtraBold.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.woff2 to
#> assets/fonts/Mulish-ExtraBold.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.eot to
#> assets/fonts/Mulish-ExtraBoldItalic.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.svg to
#> assets/fonts/Mulish-ExtraBoldItalic.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.ttf to
#> assets/fonts/Mulish-ExtraBoldItalic.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.woff to
#> assets/fonts/Mulish-ExtraBoldItalic.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.woff2 to
#> assets/fonts/Mulish-ExtraBoldItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.eot to
#> assets/fonts/Mulish-ExtraLight.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.svg to
#> assets/fonts/Mulish-ExtraLight.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.ttf to
#> assets/fonts/Mulish-ExtraLight.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.woff to
#> assets/fonts/Mulish-ExtraLight.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.woff2
#> to assets/fonts/Mulish-ExtraLight.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.eot to
#> assets/fonts/Mulish-ExtraLightItalic.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.svg to
#> assets/fonts/Mulish-ExtraLightItalic.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.ttf to
#> assets/fonts/Mulish-ExtraLightItalic.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.woff to
#> assets/fonts/Mulish-ExtraLightItalic.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.woff2 to
#> assets/fonts/Mulish-ExtraLightItalic.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic-VariableFont_wght.ttf
#> to assets/fonts/Mulish-Italic-VariableFont_wght.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.eot to
#> assets/fonts/Mulish-Italic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.svg to
#> assets/fonts/Mulish-Italic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.ttf to
#> assets/fonts/Mulish-Italic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.woff to
#> assets/fonts/Mulish-Italic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.woff2 to
#> assets/fonts/Mulish-Italic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.eot to
#> assets/fonts/Mulish-Light.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.svg to
#> assets/fonts/Mulish-Light.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.ttf to
#> assets/fonts/Mulish-Light.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.woff to
#> assets/fonts/Mulish-Light.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.woff2 to
#> assets/fonts/Mulish-Light.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.eot to
#> assets/fonts/Mulish-LightItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.svg to
#> assets/fonts/Mulish-LightItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.ttf to
#> assets/fonts/Mulish-LightItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.woff
#> to assets/fonts/Mulish-LightItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.woff2
#> to assets/fonts/Mulish-LightItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.eot to
#> assets/fonts/Mulish-Medium.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.svg to
#> assets/fonts/Mulish-Medium.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.ttf to
#> assets/fonts/Mulish-Medium.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.woff to
#> assets/fonts/Mulish-Medium.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.woff2 to
#> assets/fonts/Mulish-Medium.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.eot
#> to assets/fonts/Mulish-MediumItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.svg
#> to assets/fonts/Mulish-MediumItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.ttf
#> to assets/fonts/Mulish-MediumItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.woff
#> to assets/fonts/Mulish-MediumItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.woff2
#> to assets/fonts/Mulish-MediumItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.eot to
#> assets/fonts/Mulish-Regular.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.svg to
#> assets/fonts/Mulish-Regular.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.ttf to
#> assets/fonts/Mulish-Regular.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.woff to
#> assets/fonts/Mulish-Regular.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.woff2 to
#> assets/fonts/Mulish-Regular.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.eot to
#> assets/fonts/Mulish-SemiBold.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.svg to
#> assets/fonts/Mulish-SemiBold.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.ttf to
#> assets/fonts/Mulish-SemiBold.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.woff to
#> assets/fonts/Mulish-SemiBold.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.woff2 to
#> assets/fonts/Mulish-SemiBold.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.eot
#> to assets/fonts/Mulish-SemiBoldItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.svg
#> to assets/fonts/Mulish-SemiBoldItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.ttf
#> to assets/fonts/Mulish-SemiBoldItalic.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.woff to
#> assets/fonts/Mulish-SemiBoldItalic.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.woff2 to
#> assets/fonts/Mulish-SemiBoldItalic.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-VariableFont_wght.ttf to
#> assets/fonts/Mulish-VariableFont_wght.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.eot to
#> assets/fonts/MulishExtraLight-Regular.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.svg to
#> assets/fonts/MulishExtraLight-Regular.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.woff to
#> assets/fonts/MulishExtraLight-Regular.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.woff2 to
#> assets/fonts/MulishExtraLight-Regular.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.eot to
#> assets/fonts/mulish-v5-latin-regular.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.svg to
#> assets/fonts/mulish-v5-latin-regular.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.ttf to
#> assets/fonts/mulish-v5-latin-regular.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.woff to
#> assets/fonts/mulish-v5-latin-regular.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.woff2 to
#> assets/fonts/mulish-v5-latin-regular.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-variablefont_wght.woff to
#> assets/fonts/mulish-variablefont_wght.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-variablefont_wght.woff2 to
#> assets/fonts/mulish-variablefont_wght.woff2
#> Copying <varnish>/pkgdown/assets/assets/images/carpentries-logo-sm.svg
#> to assets/images/carpentries-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/carpentries-logo.svg to
#> assets/images/carpentries-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/data-logo-sm.svg to
#> assets/images/data-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/data-logo.svg to
#> assets/images/data-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/dropdown-arrow.svg to
#> assets/images/dropdown-arrow.svg
#> Copying <varnish>/pkgdown/assets/assets/images/incubator-logo-sm.svg to
#> assets/images/incubator-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/incubator-logo.svg to
#> assets/images/incubator-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/lab-logo-sm.svg to
#> assets/images/lab-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/lab-logo.svg to
#> assets/images/lab-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/library-logo-sm.svg to
#> assets/images/library-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/library-logo.svg to
#> assets/images/library-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/minus.svg to
#> assets/images/minus.svg
#> Copying <varnish>/pkgdown/assets/assets/images/orcid_icon.png to
#> assets/images/orcid_icon.png
#> Copying <varnish>/pkgdown/assets/assets/images/parrot_icon.svg to
#> assets/images/parrot_icon.svg
#> Copying <varnish>/pkgdown/assets/assets/images/parrot_icon_colour.svg
#> to assets/images/parrot_icon_colour.svg
#> Copying <varnish>/pkgdown/assets/assets/images/plus.svg to
#> assets/images/plus.svg
#> Copying <varnish>/pkgdown/assets/assets/images/software-logo-sm.svg to
#> assets/images/software-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/software-logo.svg to
#> assets/images/software-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/scripts.js to assets/scripts.js
#> Copying <varnish>/pkgdown/assets/assets/styles.css to assets/styles.css
#> Copying <varnish>/pkgdown/assets/assets/styles.css.map to
#> assets/styles.css.map
#> Copying <varnish>/pkgdown/assets/assets/themetoggle.js to
#> assets/themetoggle.js
#> Copying <varnish>/pkgdown/assets/favicon-16x16.png to favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicon-32x32.png to favicon-32x32.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-114x114.png to
#> favicons/cp/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-120x120.png to
#> favicons/cp/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-144x144.png to
#> favicons/cp/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-152x152.png to
#> favicons/cp/apple-touch-icon-152x152.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-57x57.png
#> to favicons/cp/apple-touch-icon-57x57.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-60x60.png
#> to favicons/cp/apple-touch-icon-60x60.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-72x72.png
#> to favicons/cp/apple-touch-icon-72x72.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-76x76.png
#> to favicons/cp/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-128.png to
#> favicons/cp/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-16x16.png to
#> favicons/cp/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-196x196.png to
#> favicons/cp/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-32x32.png to
#> favicons/cp/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-96x96.png to
#> favicons/cp/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon.ico to
#> favicons/cp/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-144x144.png to
#> favicons/cp/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-150x150.png to
#> favicons/cp/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-310x150.png to
#> favicons/cp/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-310x310.png to
#> favicons/cp/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-70x70.png to
#> favicons/cp/mstile-70x70.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-114x114.png to
#> favicons/dc/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-120x120.png to
#> favicons/dc/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-144x144.png to
#> favicons/dc/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-152x152.png to
#> favicons/dc/apple-touch-icon-152x152.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-57x57.png
#> to favicons/dc/apple-touch-icon-57x57.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-60x60.png
#> to favicons/dc/apple-touch-icon-60x60.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-72x72.png
#> to favicons/dc/apple-touch-icon-72x72.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-76x76.png
#> to favicons/dc/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-128.png to
#> favicons/dc/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-16x16.png to
#> favicons/dc/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-196x196.png to
#> favicons/dc/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-32x32.png to
#> favicons/dc/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-96x96.png to
#> favicons/dc/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon.ico to
#> favicons/dc/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-144x144.png to
#> favicons/dc/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-150x150.png to
#> favicons/dc/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-310x150.png to
#> favicons/dc/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-310x310.png to
#> favicons/dc/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-70x70.png to
#> favicons/dc/mstile-70x70.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-114x114.png to
#> favicons/lc/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-120x120.png to
#> favicons/lc/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-144x144.png to
#> favicons/lc/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-152x152.png to
#> favicons/lc/apple-touch-icon-152x152.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-57x57.png
#> to favicons/lc/apple-touch-icon-57x57.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-60x60.png
#> to favicons/lc/apple-touch-icon-60x60.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-72x72.png
#> to favicons/lc/apple-touch-icon-72x72.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-76x76.png
#> to favicons/lc/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-128.png to
#> favicons/lc/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-16x16.png to
#> favicons/lc/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-196x196.png to
#> favicons/lc/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-32x32.png to
#> favicons/lc/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-96x96.png to
#> favicons/lc/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon.ico to
#> favicons/lc/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-144x144.png to
#> favicons/lc/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-150x150.png to
#> favicons/lc/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-310x150.png to
#> favicons/lc/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-310x310.png to
#> favicons/lc/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-70x70.png to
#> favicons/lc/mstile-70x70.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-114x114.png to
#> favicons/swc/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-120x120.png to
#> favicons/swc/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-144x144.png to
#> favicons/swc/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-152x152.png to
#> favicons/swc/apple-touch-icon-152x152.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-57x57.png to
#> favicons/swc/apple-touch-icon-57x57.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-60x60.png to
#> favicons/swc/apple-touch-icon-60x60.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-72x72.png to
#> favicons/swc/apple-touch-icon-72x72.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-76x76.png to
#> favicons/swc/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-128.png to
#> favicons/swc/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-16x16.png to
#> favicons/swc/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-196x196.png to
#> favicons/swc/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-32x32.png to
#> favicons/swc/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-96x96.png to
#> favicons/swc/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon.ico to
#> favicons/swc/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-144x144.png to
#> favicons/swc/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-150x150.png to
#> favicons/swc/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-310x150.png to
#> favicons/swc/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-310x310.png to
#> favicons/swc/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-70x70.png to
#> favicons/swc/mstile-70x70.png
#> Copying <varnish>/pkgdown/assets/mstile-150x150.png to
#> mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/safari-pinned-tab.svg to
#> safari-pinned-tab.svg
#> Copying <varnish>/pkgdown/assets/site.webmanifest to site.webmanifest
#> ! No valid citation information available.
dir(file.path(tmp, "site"))
#> [1] "DESCRIPTION"   "README.md"     "_pkgdown.yaml" "built"        
#> [5] "docs"         
reset_site(tmp)
dir(file.path(tmp, "site"))
#> [1] "DESCRIPTION"   "README.md"     "_pkgdown.yaml" "built"        
```
