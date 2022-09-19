tmp <- res <- restore_fixture()
this_cfg <- fs::path(tmp, "config.yaml")
tcfg <- tempfile()
fs::file_copy(this_cfg, tcfg)

test_that("set_config() needs equal numbers of inputs", {

  # We do not have the named stopifnot in version 3, so we just skip these tests
  skip_if_not(!is.null(R.version$major) && R.version$major > 3)
  expect_error(set_config(), "please supply key/value pairs to use")
  expect_error(set_config("a"), "values must have named keys")
  val <- "a"
  names(val) <- NA
  expect_error(set_config(val), "ALL values must have named keys")
  names(val) <- " "
  expect_error(set_config(val), "ALL values must have named keys")
})

cli::test_that_cli("set_config() will set individual items", {
  expect_snapshot(
    set_config(list("title" = "test: title", "license" = "CC0"), path = tmp)
  )
}, config = c("plain"))

cli::test_that_cli("set_config() will write items", {
  fs::file_copy(tcfg, this_cfg, overwrite = TRUE)
  expect_snapshot(
    set_config(c("title" = "test: title", "license" = "CC0"), path = tmp, write = TRUE),
    transform = function(s) mask_tmpdir(s, dirname(tmp)))
})


test_that("custom keys will return an error with default", {
  suppressMessages({
  expect_snapshot_error(
    set_config(c("test-key" = "hey!", "keytest" = "yo?"), 
      path = tmp, write = TRUE, create = FALSE)
  )
  })
})


test_that("custom keys can be modified by set_config()", {
  expect_snapshot(set_config(c("test-key" = "hey!"), path = tmp, write = TRUE, create = TRUE),
    transform = function(s) mask_tmpdir(s, dirname(tmp)))
  expect_equal(get_config(tmp)[["test-key"]], "hey!")
  expect_snapshot(set_config(c("test-key" = "!yeh"), path = tmp, write = TRUE),
    transform = function(s) mask_tmpdir(s, dirname(tmp)))
  expect_equal(get_config(tmp)[["test-key"]], "!yeh")
})

test_that("schedule is empty by default", {

  cfg <- get_config(tmp)
  suppressMessages(s <- get_episodes(tmp))
  expect_equal(s, "introduction.Rmd", ignore_attr = TRUE)
  expect_null(set_episodes(tmp, s, write = TRUE))
  expect_silent(s <- get_episodes(tmp))
  expect_equal(s, "introduction.Rmd", ignore_attr = TRUE)

  # the config files should be unchanged from the schedule
  no_episodes <- names(cfg)[names(cfg) != "episodes"]
  expect_equal(cfg[no_episodes], get_config(tmp)[no_episodes])

})


test_that("new episodes will add to the schedule by default", {

  set_episodes(tmp, "introduction.Rmd", write = TRUE)
  create_episode("new", path = tmp)
  expect_equal(get_episodes(tmp), c("introduction.Rmd", "new.Rmd"), ignore_attr = TRUE)

})


test_that("get_episodes() returns episodes in dir if schedule is not set", {

  reset_episodes(tmp)
  suppressMessages(expect_message(s <- get_episodes(tmp)))
  expect_equal(s, c("introduction.Rmd", "new.Rmd"), ignore_attr = TRUE)
  set_episodes(tmp, s[1], write = TRUE)
  expect_equal(get_episodes(tmp), s[1], ignore_attr = TRUE)

})


cli::test_that_cli("set_episodes() will display the modifications if write is not specified", {

  # Is this skipped on CRAN?
  reset_episodes(tmp)
  expect_snapshot(s <- get_episodes(tmp))

  expect_equal(s, c("introduction.Rmd", "new.Rmd"))
  set_episodes(tmp, s, write = TRUE)
  expect_equal(get_episodes(tmp), s, ignore_attr = TRUE)

  expect_snapshot(set_episodes(tmp, s[1]))
  expect_equal(get_episodes(tmp), s, ignore_attr = TRUE)
  set_episodes(tmp, s[1], write = TRUE)
  expect_equal(get_episodes(tmp), s[1], ignore_attr = TRUE)

}, "plain")

test_that("set_episodes() will error if no proposal is defined", {

  expect_error(set_episodes(tmp), "episodes must have an order")

})


test_that("adding episodes will concatenate the schedule", {

  set_episodes(tmp, "introduction.Rmd", write = TRUE)
  expect_equal(get_episodes(tmp), "introduction.Rmd")
  create_episode("second-episode", add = TRUE, path = tmp)
  expect_equal(res, tmp, ignore_attr = TRUE)
  expect_equal(get_episodes(tmp), c("introduction.Rmd", "second-episode.Rmd"), ignore_attr = TRUE)

  sb <- create_sidebar(get_episodes(tmp, trim = FALSE))
  expect_length(sb, 2)
  expect_match(sb[1], "introduction.html")
  expect_match(sb[2], "second-episode.html")

})

test_that("the schedule can be rearranged", {

  set_episodes(tmp, c("second-episode.Rmd", "introduction.Rmd"), write = TRUE)
  expect_equal(get_episodes(tmp), c("second-episode.Rmd", "introduction.Rmd"), ignore_attr = TRUE)

  sb <- create_sidebar(get_episodes(tmp, trim = FALSE))
  expect_length(sb, 2)
  expect_match(sb[1], "second-episode.html")
  expect_match(sb[2], "introduction.html")

})

test_that("yaml lists are preserved with other schedule updates", {
  
  set_episodes(tmp, c("second-episode.Rmd", "introduction.Rmd"), write = TRUE)
  # regression test for https://github.com/carpentries/sandpaper/issues/53
  expect_equal(get_episodes(tmp), c("second-episode.Rmd", "introduction.Rmd"))
  set_learners(tmp, order = "setup.md", write = TRUE) # ZNK 2021-07: force this line to be recognized by Git
  expect_equal(get_episodes(tmp), c("second-episode.Rmd", "introduction.Rmd"))

})

test_that("the schedule can be truncated", {

  set_episodes(tmp, "introduction.Rmd", write = TRUE)
  expect_equal(get_episodes(tmp), "introduction.Rmd", ignore_attr = TRUE)

  sb <- create_sidebar(get_episodes(tmp, trim = FALSE))
  expect_length(sb, 1)
  expect_match(sb[1], "introduction.html")

  skip_if_not(rmarkdown::pandoc_available("2.11"))

  # build the lesson here just to be absolutely sure
  withr::defer(use_package_cache(prompt = FALSE, quiet = TRUE))
  no_package_cache()
  expect_silent(build_lesson(tmp, quiet = TRUE, preview = FALSE))
  html <- xml2::read_html(fs::path(tmp, "site/docs/index.html"))
  episodes <- xml2::xml_find_all(html, 
    ".//div[contains(@class, 'accordion-header')]/a")
  links <- xml2::xml_attr(episodes, "href")
  expect_length(links, 1)
  expect_equal(links[1], "introduction.html")

})
