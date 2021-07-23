# Destruction of the .gitignore file renders the lesson incorrect [plain]

    Code
      expect_error(check_lesson(tmp), "There were errors with the lesson structure")
    Message <cliMessage>
      ! The .gitignore file is missing the following elements:
      episodes/*html
      site/*
      !site/README.md
      .Rhistory
      .Rapp.history
      .RData
      .Ruserdata
      *-Ex.R
      /*.tar.gz
      /*.Rcheck/
      .Rproj.user/
      vignettes/*.html
      vignettes/*.pdf
      .httr-oauth
      *_cache/
      /cache/
      *.utf8.md
      *.knit.md
      .Renviron
      docs/
      po/*~

# Destruction of the .gitignore file renders the lesson incorrect [ansi]

    Code
      expect_error(check_lesson(tmp), "There were errors with the lesson structure")
    Message <cliMessage>
      [31m![39m The .gitignore file is missing the following elements:
      episodes/*html
      site/*
      !site/README.md
      .Rhistory
      .Rapp.history
      .RData
      .Ruserdata
      *-Ex.R
      /*.tar.gz
      /*.Rcheck/
      .Rproj.user/
      vignettes/*.html
      vignettes/*.pdf
      .httr-oauth
      *_cache/
      /cache/
      *.utf8.md
      *.knit.md
      .Renviron
      docs/
      po/*~

# Destruction of the .gitignore file renders the lesson incorrect [unicode]

    Code
      expect_error(check_lesson(tmp), "There were errors with the lesson structure")
    Message <cliMessage>
      ! The .gitignore file is missing the following elements:
      episodes/*html
      site/*
      !site/README.md
      .Rhistory
      .Rapp.history
      .RData
      .Ruserdata
      *-Ex.R
      /*.tar.gz
      /*.Rcheck/
      .Rproj.user/
      vignettes/*.html
      vignettes/*.pdf
      .httr-oauth
      *_cache/
      /cache/
      *.utf8.md
      *.knit.md
      .Renviron
      docs/
      po/*~

# Destruction of the .gitignore file renders the lesson incorrect [fancy]

    Code
      expect_error(check_lesson(tmp), "There were errors with the lesson structure")
    Message <cliMessage>
      [31m![39m The .gitignore file is missing the following elements:
      episodes/*html
      site/*
      !site/README.md
      .Rhistory
      .Rapp.history
      .RData
      .Ruserdata
      *-Ex.R
      /*.tar.gz
      /*.Rcheck/
      .Rproj.user/
      vignettes/*.html
      vignettes/*.pdf
      .httr-oauth
      *_cache/
      /cache/
      *.utf8.md
      *.knit.md
      .Renviron
      docs/
      po/*~

