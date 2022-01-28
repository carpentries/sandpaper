res <- restore_fixture()
nossel_store <- .lesson_store()

test_that("lesson store can be independently created", {
  expect_type(nossel_store, "list")
  expect_named(nossel_store, c("get", "valid", "set", "clear"))
})

test_that("lesson store starts off as NULL", {
  expect_null(nossel_store$get())
})

test_that("lesson store can be set and returns a lesson", {
  nossel_store$set(res)
  expect_s3_class(nossel_store$get(), "Lesson")
  expect_true(nossel_store$valid(res))
})

test_that("lesson store can be cleared", {
  nossel_store$clear()
  expect_null(nossel_store$get())
})

