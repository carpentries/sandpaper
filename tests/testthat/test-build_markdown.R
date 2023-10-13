# setup test fixture
{
tmp <- res <- restore_fixture()
create_episode("second-episode", path = tmp)
instruct <- fs::path(tmp, "instructors", "pyramid.md")
writeLines(c(
  "---",
  "title: Pyramid",
  "---\n",
  "One of the best albums by MJQ"
 ),
  con = instruct
)
fs::file_copy(instruct, fs::path(tmp, "learners", "dimaryp.md"))
set_globals(res)
withr::defer(clear_globals())
}


test_that("markdown sources can be built without fail", {

  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)
  set_learners(tmp, "dimaryp.md", write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)
  # The episodes should be the only things in the directory
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  s <- get_episodes(tmp)
  expect_equal(fs::path_file(e), s, ignore_attr = TRUE)

  skip_if_not(rmarkdown::pandoc_available("1.12.3"))
  # Accidentally rendered html live in their parent folders
  rmarkdown::render(instruct, quiet = TRUE)
  expect_true(fs::file_exists(fs::path_ext_set(instruct, "html")))

  # keep original config in a tmp file
  tmp_config <- withr::local_tempfile()
  fs::file_copy(fs::path(res, "config.yaml"), tmp_config)
  # clean up by replacing config with original
  withr::defer(
    {
      fs::file_copy(tmp_config, fs::path(res, "config.yaml"), overwrite = TRUE)
      ch <- fs::path(res, "site", "built", "files", "code-handout.R")
      if (fs::file_exists(ch)) {
        fs::file_delete(ch)
      }
      this_metadata$set("handout", NULL)
    },
    priority = "first"
  )
  cat("handout: true\n", file = fs::path(res, "config.yaml"), append = TRUE)

  # It's noisy at first
  suppressMessages({
    build_markdown(res, quiet = FALSE) %>%
      expect_message("Consent to use package cache (provided|not given)") %>%
      expect_output(processing_("second-episode.Rmd"))
  })

  # # Accidentaly rendered HTML is removed before building
  expect_false(fs::file_exists(fs::path_ext_set(instruct, "html")))
  build_path <- function(...) fs::path(res, "site", "built", ...)
  expect_true(fs::file_exists(build_path("files", "code-handout.R")))
  expect_true(fs::file_exists(build_path("pyramid.md")))
  expect_true(fs::file_exists(build_path("dimaryp.md")))
  expect_true(fs::file_exists(build_path("setup.md")))
})

test_that("changes in config.yaml triggers a rebuild of the site yaml", {
  skip_if_not(rmarkdown::pandoc_available("1.12.3"))
  yml <- get_path_site_yaml(res)$title
  expect_identical(yml, "Lesson Title")
  cfg <- gsub(
    "Lesson Title", "NEW: Lesson Title",
    readLines(fs::path(res, "config.yaml"))
  )
  writeLines(cfg, fs::path(res, "config.yaml"))

  suppressMessages({
    out <- capture.output({
      build_markdown(res, quiet = FALSE) %>%
        expect_message("nothing to rebuild")
    })
  })

  expect_identical(get_path_site_yaml(res)$title, "NEW: Lesson Title")


})




test_that("markdown sources can be rebuilt without renv", {

  # no building needed
  skip_on_os("windows")
  suppressMessages({
    out <- capture.output({
      build_markdown(res, quiet = FALSE) %>%
        expect_message("nothing to rebuild")
    })
  })
  expect_length(out, 0)

  withr::local_options(list(sandpaper.use_renv = FALSE))
  # everything rebuilt
  expect_false(getOption("sandpaper.use_renv"))
  suppressMessages({
    build_markdown(res, quiet = FALSE, rebuild = TRUE) %>%
      expect_message("Consent to use package cache not given.") %>%
      expect_output(processing_("second-episode")) # chunk name from template episode
  })
  expect_false(getOption("sandpaper.use_renv"))
})

test_that("modifying a file suffix will force the file to be rebuilt", {

  instruct <- fs::path(tmp, "instructors", "pyramid.md")
  instruct_rmd <- fs::path_ext_set(instruct, "Rmd")
  expect_true(fs::file_exists(instruct))

  # If we change a markdown file to an Rmarkdown file,
  # that file should be rebuilt
  fs::file_move(instruct, instruct_rmd)
  expect_false(fs::file_exists(instruct))
  expect_true(fs::file_exists(instruct_rmd))

  withr::defer({
    # reset source file
    fs::file_move(instruct_rmd, instruct)
    # rebuild database
    suppressMessages(build_markdown(res, quiet = TRUE))
  })

  # Test that the birth times are changed.
  skip_on_os("windows")
  old_info <- fs::file_info(fs::path(tmp, "site", "built", "pyramid.md"))
  suppressMessages({
    build_markdown(res, quiet = TRUE)
  })
  new_info <- fs::file_info(fs::path(tmp, "site", "built", "pyramid.md"))
  expect_gt(new_info$birth_time, old_info$birth_time)
})

test_that("Artifacts are accounted for", {

  s <- get_episodes(tmp)
  # The artifacts are present in the built directory
  b <- c(
    "CODE_OF_CONDUCT.md",
    "LICENSE.md",
    "setup.md",
    "index.md",
    "instructor-notes.md",
    "links.md",
    "learner-profiles.md",
    "pyramid.md",
    "dimaryp.md",
    # Generated markdown files
    fs::path_ext_set(s, "md"),
    "config.yaml",
    if (.Platform$OS.type != "windows") "renv.lock",
    "md5sum.txt"
  )

  # No artifacts should be present in the source dir --------------
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(e), s, ignore_attr = TRUE)

  # Testing for top-level artifacts -------------------------------
  folders <- c( "data", "fig", "files")
  a <- fs::dir_ls(fs::path(tmp, "site", "built"))
  expect_setequal(fs::path_file(a), c(folders, b))

  # Testing for generated figures included ------------------------
  figs <- paste0(fs::path_ext_remove(s), "-rendered-pyramid-1.png")
  a <- fs::dir_ls(fs::path(tmp, "site", "built"), recurse = TRUE, type = "file")
  expect_setequal(fs::path_file(a), c(figs, b, "code-handout.R"))

})

test_that("Hashes are correct", {
  # see helper-hash.R
  h1 <- expect_hashed(res, "introduction.Rmd")
  h2 <- expect_hashed(res, "second-episode.Rmd")
  # the hashes will no longer be equal because the titles are now different
  expect_failure(expect_equal(h1, h2, ignore_attr = TRUE))

})

test_that("Output is not commented", {
  # Output is not commented
  built  <- get_markdown_files(res)
  built_file <- grep("introduction.md$", built)
  ep     <- trimws(readLines(built[[built_file]]))
  ep     <- ep[ep != ""]
  outid  <- grep("[1]", ep, fixed = TRUE)
  output <- ep[outid[1]]
  fence  <- ep[outid[1] - 1]

  # code output lines start with normal R indexing ---------------
  expect_match(output, "^\\[1\\]")
  # code output fences have the output class ---------------------
  expect_match(fence, "^[`]{3}[{]?\\.?output[}]?")

})

test_that("Markdown rendering does not happen if content is not changed", {

  skip_on_os("windows")

  suppressMessages({
    expect_message(out <- capture.output(build_markdown(res)), "nothing to rebuild")
  })
  expect_length(out, 0)

  fs::file_touch(fs::path(res, "episodes", "introduction.Rmd"))

  suppressMessages({
    expect_message(out <- capture.output(build_markdown(res)), "nothing to rebuild")
  })
  expect_length(out, 0)
})

test_that("Removing source removes built", {
  # Removing files will result in the markdown files being removed
  e2 <- fs::path(res, "episodes", "second-episode.Rmd")
  built_path <- path_built(res)
  fs::file_delete(e2)
  reset_episodes(res)
  set_episodes(res, "introduction.Rmd", write = TRUE)
  build_markdown(res, quiet = TRUE)
#  h1 <- expect_hashed(res, "introduction.Rmd")
  expect_length(get_figs(res, "introduction"), 1)

  # The second episode should not exist
  expect_false(fs::file_exists(e2))
  expect_false(fs::file_exists(fs::path(built_path, "second-episode.md")))

  # The figures for the second episode should not exist either
  expect_length(get_figs(res, "second-episode"), 0)
})

test_that("old md5sum.txt db will work", {
  # Databases built with sandpaper versions < 0.0.0.9028 will still work:
  db_path <- fs::path(res, "site", "built", "md5sum.txt")
  olddb <- db <- get_built_db(db_path, "*")
  withr::defer({
    write_build_db(olddb, db_path)
  })
  db$file <- fs::path(res, db$file)
  db$built <- fs::path(res, db$built)
  write_build_db(db, db_path)
  sources <- unlist(get_resource_list(res), use.names = FALSE)
  newdb <- build_status(sources, db_path, rebuild = FALSE, write = FALSE)

  # Pages that used the old version will go through a full revision, meaning
  # that the previously built pages will need to be removed
  expect_length(newdb$remove, length(sources))

  # All of the resources appear to exist
  expect_true(all(fs::file_exists(newdb$remove)))
  expect_true(all(fs::file_exists(newdb$build)))

  # The absolute paths of the old versions represent actual files
  expect_identical(db$built, newdb$remove)

  # The new database format is restored
  expect_identical(olddb$file, as.character(newdb$new$file))

})

test_that("dates are preserved in md5sum.txt", {
  db_path <- fs::path(res, "site", "built", "md5sum.txt")
  olddb <- db <- get_built_db(db_path, "*")
  withr::defer({
    write_build_db(olddb, db_path)
  })
  db$date <- format(as.Date(db$date, "%F") + sample(-10:10, nrow(db)), "%F")
  write_build_db(db, db_path)
  sources <- unlist(get_resource_list(res), use.names = FALSE)
  newdb <- build_status(sources, db_path, rebuild = FALSE, write = FALSE)

  expect_equal(newdb$new$date, db$date)

})

test_that("Removing partially matching slugs will not have side-effects", {
  built_path <- path_built(res)

  fs::file_delete(fs::path(res, "instructors", "pyramid.md"))
  build_markdown(res, quiet = TRUE)
  h1 <- expect_hashed(res, "introduction.Rmd")
  expect_length(get_figs(res, "introduction"), 1)

  # The deleted file should be properly removed
  expect_false(fs::file_exists(fs::path(built_path, "pyramid.md")))

  # The image should still exist
  pyramid_fig <- fs::path(built_path, "fig", "introduction-rendered-pyramid-1.png")
  expect_true(fs::file_exists(pyramid_fig))

})

test_that("setting `fail_on_error: true` in config will cause build to fail", {
  # fail_on_error is NULL by default
  expect_null(this_metadata$get()[["fail_on_error"]])
  old_yaml <- withr::local_tempfile()
  old_episode <- withr::local_tempfile()
  suppressMessages(episode <- get_episodes(res, trim = FALSE)[[1]])
  yaml <- fs::path(res, "config.yaml")
  fs::file_copy(yaml, old_yaml)
  fs::file_copy(episode, old_episode)
  withr::defer({
    fs::file_copy(old_yaml, yaml, overwrite = TRUE)
    fs::file_copy(old_episode, episode, overwrite = TRUE)
  })
  ep <- pegboard::Episode$new(episode)$confirm_sandpaper()
  # Adding two errors to the top of the document. The first one will not error
  # because it has `error = TRUE`, meaning that it will pass.
  noerr <- "```{r this-will-not-error, error=TRUE}\nstop('hammertime')\n```\n"
  # The second error will throw an error because it does not have an error=TRUE
  err <- "```{r this-will-error}\nstop('in the name of love')\n```\n"
  ep$add_md(err, 1L)
  ep$add_md(noerr, 1L)
  ep$write(fs::path(res, "episodes"), format = "Rmd")
  cat("fail_on_error: true\n", file = yaml, append = TRUE)
  # Important context for the test: there are two chunks in the top of the
  # document that will throw errors in this order:
  #
  # 1. hammertime
  # 2. in the name of love
  #
  # The first chunk is allowed to show the error in the document, the second
  # is not. When we check for the text of the second error, that confirms that
  # the first error is passed over
  suppressMessages({
    out <- capture.output({
      build_markdown(res, quiet = FALSE) %>%
        expect_message("use error=TRUE") %>%
        expect_error("in the name of love")
    })
  })
  # fail on error is true
  expect_true(this_metadata$get()[["fail_on_error"]])
})
