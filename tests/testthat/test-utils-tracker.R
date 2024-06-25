test_that("analytics carpentries tracker code generation works", {
    tracker_yaml <- "analytics: carpentries"

    YML <- yaml::yaml.load(tracker_yaml)

    tracker_str <- processTracker(siQuote(YML$analytics))

    expect_true(length(tracker_str) > 0)
    expect_false(identical(tracker_str, "carpentries"))
})
