test_that("template files point to the right places", {
  expect_equal(fs::path_file(template_gitignore()), "gitignore-template.txt")
  expect_equal(fs::path_file(template_episode()), "episode-template.txt")
  expect_equal(fs::path_file(template_config()), "config-template.txt")
  expect_equal(fs::path_file(template_links()), "links-template.txt")
})

