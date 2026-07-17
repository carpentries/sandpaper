test_that("siQuote works for normally escaped strings", {

  test_string <- "unquoted string?: \"that contains $unescaped quotes!\""
  expect_equal(siQuote(character(0)), "")
  expect_equal(siQuote(""), "")
  expect_equal(siQuote("hello: there"), "'hello: there'")

  expectation <- paste0("'", test_string, "'")
  expect_equal(siQuote(test_string), expectation)
  expect_equal(siQuote(expectation), expectation)

  test_single <- "a string?: [with] 'single quotes' and \"unescaped double quotes\" wow!"
  expectation <- "\"a string?: [with] 'single quotes' and \\\"unescaped double quotes\\\" wow!\""
  expect_equal(siQuote(test_single), expectation)
  expect_equal(siQuote(expectation), expectation)

})

cli::test_that_cli("polite yaml throws a message when there is no yaml", {

  withr::local_file(tmp <- tempfile())
  cat("A malformed YAML header\n---\n", file = tmp)
  expect_message(politely_get_yaml(tmp), "First line is invalid")

  cat("foo---\nAnother malformed YAML header\n---\n", file = tmp)
  expect_message(politely_get_yaml(tmp), "First line is invalid")

  cat("---\nYet another malformed YAML header\n# Start of markdown\n\nFoo bar baz\n", file = tmp)
  expect_message(politely_get_yaml(tmp), "Cannot find valid open and close of YAML frontmatter")

  cat("---\n\nA malformed YAML block\n---\n", file = tmp)
  expect_message(politely_get_yaml(tmp), "Blank line after first YAML block line")

  cat("# A header\n\nbut no yaml :/\n", file = tmp)
  expect_message(politely_get_yaml(tmp), "No yaml header found in the first 10 lines")


})


test_that("polite yaml works", {

yaml <- "---
a: |
  this


  is some








   poetry?









b: is it?
---

This is not poetry
"

  withr::local_file(tmp <- tempfile())
  cat(yaml, file = tmp, sep = "\n")
  rl <- readLines(tmp)
  pgy <- politely_get_yaml(tmp)
  YML <- yaml::yaml.load(pgy)

  expect_true(length(rl) > length(pgy))
  expect_true(length(pgy) == 26)
  expect_true(length(YML) == 2)
  expect_named(YML, c("a", "b"))

})


test_that("yaml_list() processes nested lists", {

  x <- letters[1:3]
  nester <- list(b = x, a = list(hello = x, jello = as.list(setNames(x, rev(x)))))
  expect_snapshot_output(writeLines(yaml_list(nester)))
})


test_that("get_lesson_customization() process customisation yamls", {
  lsn <- fs::file_temp(pattern = "lesson-")
  withr::defer(fs::dir_delete(lsn))
  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules"), recurse = TRUE)
  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "custom", "snippets", "modules"), recurse = TRUE)

  writeLines(c(
    "use_snippets: true",
    "base_snippets: base"
  ), fs::path(lsn, "config.yaml"))

  writeLines(c(
    "snippets: base",
    "sched:",
    "  name: Slurm",
    "remote:",
    "  prompt: base"
  ), fs::path(lsn, "episodes", "files", "customization", "base", "_config_options.yml"))

  writeLines("base text", fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules", "example.Rmd"))
  writeLines(c(
    "snippets: custom",
    "sched: ~",
    "remote:",
    "  prompt: custom"
  ), fs::path(lsn, "episodes", "files", "customization", "custom", "_config_options.yml"))

  writeLines("custom text", fs::path(lsn, "episodes", "files", "customization", "custom", "snippets", "modules", "example.Rmd"))

  withr::local_envvar(list(HPCC_CUSTOM_CONFIG = "base"))
  cfg_env <- get_lesson_customization(lsn)
  expect_equal(cfg_env$config$remote$prompt, "base")
  expect_match(cfg_env$snippets("modules/example.Rmd", render = FALSE), "base")

  withr::local_envvar(list(HPCC_CUSTOM_CONFIG = "custom"))
  cfg_env_name <- get_lesson_customization(lsn)
  expect_equal(cfg_env_name$config$remote$prompt, "custom")
  expect_equal(cfg_env_name$config$sched$name, "Slurm")
  expect_match(cfg_env_name$snippets("modules/example.Rmd", render = FALSE), "custom")
})


test_that("has_snippets_config() requires use_snippets and valid base_snippets", {
  lsn <- fs::file_temp(pattern = "lesson-")
  withr::defer(fs::dir_delete(lsn))
  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "base", "snippets"), recurse = TRUE)

  writeLines("title: demo", fs::path(lsn, "config.yaml"))
  expect_false(has_snippets_config(lsn))

  writeLines(c("use_snippets: true", "base_snippets: does-not-exist"), fs::path(lsn, "config.yaml"))
  expect_false(has_snippets_config(lsn))

  writeLines(c("use_snippets: true", "base_snippets: base"), fs::path(lsn, "config.yaml"))
  expect_false(has_snippets_config(lsn))

  writeLines("snippets: base", fs::path(lsn, "episodes", "files", "customization", "base", "_config_options.yml"))
  expect_true(has_snippets_config(lsn))
})

test_that("get_snippets_hash() changes when snippet files or config changes", {
  lsn <- fs::file_temp(pattern = "lesson-")
  withr::defer(fs::dir_delete(lsn))
  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules"), recurse = TRUE)
  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "custom", "snippets", "modules"), recurse = TRUE)

  writeLines(c("use_snippets: true", "base_snippets: base"), fs::path(lsn, "config.yaml"))
  writeLines(c("snippets: base", "remote:", "  prompt: v1"),
    fs::path(lsn, "episodes", "files", "customization", "base", "_config_options.yml"))
  writeLines("snippet v1", fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules", "example.Rmd"))

  withr::local_envvar(list(HPCC_CUSTOM_CONFIG = ""))
  hash1 <- get_snippets_hash(lsn)
  expect_type(hash1, "character")

  # Changing a snippet file changes the hash
  writeLines("snippet v2", fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules", "example.Rmd"))
  hash2 <- get_snippets_hash(lsn)
  expect_false(identical(hash1, hash2))

  # Switching to a custom snippets folder changes the hash
  writeLines(c("snippets: custom", "remote:", "  prompt: custom"),
    fs::path(lsn, "episodes", "files", "customization", "custom", "_config_options.yml"))
  writeLines("snippet custom", fs::path(lsn, "episodes", "files", "customization", "custom", "snippets", "modules", "example.Rmd"))
  writeLines(c("use_snippets: true", "base_snippets: base", "custom_snippets: custom"),
    fs::path(lsn, "config.yaml"))
  hash3 <- get_snippets_hash(lsn)
  expect_false(identical(hash2, hash3))

  # No snippets config => NULL hash
  writeLines("title: demo", fs::path(lsn, "config.yaml"))
  hash_none <- get_snippets_hash(lsn)
  expect_null(hash_none)
})

test_that("build_status() mixes snippets hash into episode checksums", {
  lsn <- fs::file_temp(pattern = "lesson-")
  withr::defer(fs::dir_delete(lsn))
  create_lesson(lsn, rmd = FALSE, open = FALSE)
  fs::dir_create(fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules"), recurse = TRUE)

  # Append snippet keys to existing config so source: is preserved
  cat(c("use_snippets: true", "base_snippets: base"), sep = "\n",
    file = fs::path(lsn, "config.yaml"), append = TRUE)
  writeLines(c("snippets: base", "remote:", "  prompt: v1"),
    fs::path(lsn, "episodes", "files", "customization", "base", "_config_options.yml"))
  writeLines("snippet v1", fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules", "example.Rmd"))

  # Add a snippet-using Rmd episode
  ep <- fs::path(lsn, "episodes", "test.Rmd")
  writeLines(c("---", "title: test", "---", "`r config$remote$prompt`"), ep)
  set_episodes(lsn, c("introduction.md", "test.Rmd"), write = TRUE)
  db_path <- fs::path(lsn, "site", "built", "md5sum.txt")

  withr::local_envvar(list(HPCC_CUSTOM_CONFIG = ""))
  withr::local_options(list(sandpaper.use_renv = FALSE))

  sources <- c(
    fs::path(lsn, "config.yaml"),
    fs::path(lsn, "episodes", "introduction.md"),
    ep
  )
  # First build: establish the database
  build_status(sources, db_path, rebuild = FALSE, write = TRUE)
  db1 <- get_built_db(db_path, filter = "*")
  checksum1 <- db1$checksum[db1$file == "episodes/test.Rmd"]
  expect_length(checksum1, 1L)

  # Changing a snippet file should produce a different checksum for the episode
  writeLines("snippet v2", fs::path(lsn, "episodes", "files", "customization", "base", "snippets", "modules", "example.Rmd"))
  status2 <- build_status(sources, db_path, rebuild = FALSE, write = FALSE)
  checksum2 <- status2$new$checksum[status2$new$file == "episodes/test.Rmd"]
  expect_false(identical(checksum1, checksum2))
  # episode should be flagged for rebuild
  expect_true(ep %in% status2$build)
})
