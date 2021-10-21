test_that("template files point to the right places", {
  expect_equal(fs::path_file(template_gitignore()), "gitignore-template.txt")
  expect_equal(fs::path_file(template_episode()), "episode-template.txt")
  expect_equal(fs::path_file(template_config()), "config-template.txt")
  expect_equal(fs::path_file(template_links()), "links-template.txt")
})

test_that("template_pkgdown() protects string values", {

  yaml <- get_yaml_text(template_pkgdown())
  # This would normally throw an error
  yaml <- whisker::whisker.render(yaml, data = list(title = "a: b"))
  expect_match(yaml, "title: 'a: b'")

})

test_that("template_config() protects string values", {
  
  yaml <- get_yaml_text(template_config())
  yaml <- whisker::whisker.render(yaml, data = list(title = "a: b"))
  expect_match(yaml, "title: 'a: b'")

})
