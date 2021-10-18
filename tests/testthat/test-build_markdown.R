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
}


test_that("markdown sources can be built without fail", {
  
  suppressMessages(s <- get_episodes(tmp))
  set_episodes(tmp, s, write = TRUE)
  expect_equal(res, tmp, ignore_attr = TRUE)
  # The episodes should be the only things in the directory
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  s <- get_episodes(tmp)
  expect_equal(fs::path_file(e), s, ignore_attr = TRUE)

  skip_if_not(rmarkdown::pandoc_available("1.12.3"))
  # Accidentally rendered html live in their parent folders
  rmarkdown::render(instruct, quiet = TRUE)
  expect_true(fs::file_exists(fs::path_ext_set(instruct, "html"))) 

  withr::local_options(list(sandpaper.handout = TRUE))
  # It's noisy at first
  suppressMessages({
    build_markdown(res, quiet = FALSE) %>%
      expect_message("Consent to use package cache (provided|not given)") %>%
      expect_output("ordinary text without R code")
  })

  # # Accidentaly rendered HTML is removed before building
  expect_false(fs::file_exists(fs::path_ext_set(instruct, "html")))
  expect_true(fs::file_exists(fs::path(res, "site", "built", "files", "code-handout.R")))
  fs::file_delete(fs::path(res, "site", "built", "files", "code-handout.R"))
  
})

test_that("changes in config.yaml triggers a rebuild of the site yaml", {

  skip_on_os("windows")
  yml <- get_path_site_yaml(res)$title
  expect_identical(yml, "Lesson Title")
  cfg <- gsub("Lesson Title", "NEW Lesson Title", readLines(fs::path(res, "config.yaml")))
  writeLines(cfg, fs::path(res, "config.yaml"))

  suppressMessages({
    out <- capture.output({
      build_markdown(res, quiet = FALSE) %>%
        expect_message("nothing to rebuild")
    })
  })

  expect_identical(get_path_site_yaml(res)$title, "NEW Lesson Title")


})


test_that("build_home() will refelct the title in the heading", {
  pkg <- pkgdown::as_pkgdown(fs::path(res, "site"))
  fs::dir_create(pkg$dst_path)
  expect_silent(build_home(pkg, quiet = TRUE))
  idx <- fs::path(pkg$dst_path, "index.html")
  htm <- xml2::read_html(idx)
  h1 <- xml2::xml_text(xml2::xml_find_first(htm, ".//h1"))
  expect_identical(h1, "NEW Lesson Title")
})


test_that("markdown sources can be rebuilt without fail", {
  
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
      expect_output("ordinary text without R code")
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
  # No artifacts should be present in the directory
  e <- fs::dir_ls(fs::path(tmp, "episodes"), recurse = TRUE, type = "file")
  expect_equal(fs::path_file(e), s, ignore_attr = TRUE)
  # The artifacts are present in the built directory
  b <- c(
    # Generated markdown files
    fs::path_ext_set(s, "md"), 
    "CODE_OF_CONDUCT.md", 
    "LICENSE.md", 
    "config.yaml",
    if (.Platform$OS.type != "windows") "renv.lock",
    "setup.md",
    # Folders
    "data", 
    "fig",
    "files",
    "index.md",
    "instructor-notes.md",
    "learner-profiles.md",
    "md5sum.txt",
    "pyramid.md"
  )
  a <- fs::dir_ls(fs::path(tmp, "site", "built"))
  expect_setequal(fs::path_file(a), b)
  b <- c(
    # Generated markdown files
    fs::path_ext_set(s, "md"), 
    "CODE_OF_CONDUCT.md", 
    "LICENSE.md", 
    "config.yaml",
    if (.Platform$OS.type != "windows") "renv.lock",
    "setup.md",
    # Generated figures
    paste0(fs::path_ext_remove(s), "-rendered-pyramid-1.png"),
    "index.md",
    "instructor-notes.md",
    "learner-profiles.md",
    "md5sum.txt",
    "pyramid.md"
  )
  a <- fs::dir_ls(fs::path(tmp, "site", "built"), recurse = TRUE, type = "file")
  expect_setequal(fs::path_file(a), b)

})

test_that("Hashes are correct", {
  # see helper-hash.R
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  h2 <- expect_hashed(res, "02-second-episode.Rmd")
  expect_equal(h1, h2, ignore_attr = TRUE)

})

test_that("Output is not commented", {
  # Output is not commented
  built  <- get_markdown_files(res)
  ep     <- trimws(readLines(built[[1]]))
  ep     <- ep[ep != ""]
  outid  <- grep("[1]", ep, fixed = TRUE)
  output <- ep[outid[1]]
  fence  <- ep[outid[1] - 1]
  expect_match(output, "^\\[1\\]")
  expect_match(fence, "^[`]{3}[{]\\.output[}]")

})

test_that("Markdown rendering does not happen if content is not changed", {

  skip_on_os("windows")
  
  suppressMessages({
    expect_message(out <- capture.output(build_markdown(res)), "nothing to rebuild")
  })
  expect_length(out, 0)

  fs::file_touch(fs::path(res, "episodes", "01-introduction.Rmd"))

  suppressMessages({
    expect_message(out <- capture.output(build_markdown(res)), "nothing to rebuild")
  })
  expect_length(out, 0)
})

test_that("Removing source removes built", {
  # Removing files will result in the markdown files being removed
  e2 <- fs::path(res, "episodes", "02-second-episode.Rmd")
  built_path <- path_built(res)
  fs::file_delete(e2)
  reset_episodes(res)
  set_episodes(res, "01-introduction.Rmd", write = TRUE)
  build_markdown(res, quiet = TRUE)
#  h1 <- expect_hashed(res, "01-introduction.Rmd")
  expect_length(get_figs(res, "01-introduction"), 1)

  # The second episode should not exist
  expect_false(fs::file_exists(e2))
  expect_false(fs::file_exists(fs::path(built_path, "02-second-episode.md")))

  # The figures for the second episode should not exist either
  expect_length(get_figs(res, "02-second-episode"), 0)
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

test_that("Removing partially matching slugs will not have side-effects", {
  built_path <- path_built(res)
  
  fs::file_delete(fs::path(res, "instructors", "pyramid.md"))
  build_markdown(res, quiet = TRUE)
  h1 <- expect_hashed(res, "01-introduction.Rmd")
  expect_length(get_figs(res, "01-introduction"), 1)

  # The deleted file should be properly removed
  expect_false(fs::file_exists(fs::path(built_path, "pyramid.md")))

  # The image should still exist
  pyramid_fig <- fs::path(built_path, "fig", "01-introduction-rendered-pyramid-1.png")
  expect_true(fs::file_exists(pyramid_fig))
  
})
