res <- restore_fixture()

test_that("metadata can be initialised and cleared", {

  this_metadata$clear()
  expect_length(this_metadata$get(), 0L)

  initialise_metadata(res)
  on.exit(this_metadata$clear())

  expect_type(this_metadata$get(), "list")
  expect_gt(length(this_metadata$get()), 0L)

})

test_that("metadata can be initialised with custom items added ", {
  initialise_metadata(res)
  on.exit(this_metadata$clear())
  # metadata has same values as config
  expect_equal(this_metadata$get()[["carpentry"]], "incubator")
  met <- create_metadata_jsonld(res,
    date = list(created = "2022-02-01", modified = "2022-02-08", published = "2022-02-09"),
    pagetitle = "The Importance of Being Ernest Scared Stupid",
    url = "https://zkamvar.github.io/lesson-example/vern.html"
  )
  expect_type(met, "character")
  expect_match(met, "Ernest Scared Stupid")
  expect_match(met, "\"inLanguage\": \"en\"", fixed = TRUE)
  expect_length(met, 1L)
  skip_on_os("windows") # dang carriage returns
  expect_snapshot_value(met)

  met <- create_metadata_jsonld(res,
    pagetitle = "The Importance of Being Ernest Scared Stupid",
    url = "https://zkamvar.github.io/lesson-example/vern.html",
    lang = "es_AR"
  )
  expect_type(met, "character")
  expect_match(met, "Ernest Scared Stupid")
  expect_match(met, "\"inLanguage\": \"es-AR\"", fixed = TRUE)
  expect_length(met, 1L)
})


