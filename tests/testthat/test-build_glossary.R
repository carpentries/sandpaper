
tmp <- res <- restore_fixture()

metadata_json <- trimws(create_metadata_jsonld(tmp))
sitepath <- fs::path(tmp, "site", "docs")
pkg <- pkgdown::as_pkgdown(fs::path_dir(sitepath))

config_path <- fs::path(tmp, "config.yaml")
config <- yaml::read_yaml(config_path)
config$lang <- "de"
glosario_path <- fs::path(tmp, "glossary.yml")
yaml::write_yaml(
  list(
    list(
      slug = "algorithm",
      en = list(
        term = "Algorithm",
        def = "A sequence of steps to solve a problem."
      ),
      de = list(
        term = "Algorithmus",
        def = "Eine Folge von Schritten, um ein Problem zu losen."
      )
    )
  ),
  glosario_path
)
config$glosario <- "glossary.yml"
yaml::write_yaml(config, config_path)

test_that("Glossary files are present and have the correct elements", {

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # Build the lesson with the new 'de' config
  suppressMessages(build_lesson(tmp, preview = FALSE, quiet = TRUE))
  ref <- fs::path(sitepath, "reference.html")

  content <- get_content(ref, "/section[@id='glosario']", pkg = pkg, instructor = FALSE)
  expect_length(content, 1L)
})
