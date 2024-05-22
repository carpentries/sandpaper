test_that("analytics carpentries tracker code generation works", {
    yaml <- "
      analytics: carpentries
    "

    expectation <- "

    "
    pgy <- politely_get_yaml(yaml)
    YML <- yaml::yaml.load(pgy)

    tracker_str <- processTracker(siQuote(YML$analytics))

    expect_true(length(tracker_str) > 0)
    expect_false(identical(tracker_str, "carpentries"))
})