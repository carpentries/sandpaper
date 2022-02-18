res <- restore_fixture()
nossel_store <- .lesson_store()
tsil_store <- .list_store()
tsilly <- tsil_store$copy()

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

test_that("lesson stores can be invalidated", {
  
  expect_true(nossel_store$valid(res))
  cat("HELLO\n", file = fs::path(res, "README.md"), append = TRUE)
  expect_false(nossel_store$valid(res))

})

test_that("lesson store can be cleared", {
  nossel_store$clear()
  expect_null(nossel_store$get())
})


test_that("list stores are list-store objects", {
  expect_s3_class(tsil_store, "list-store")
  expect_length(tsil_store, 5L)
  expect_named(tsil_store, c("get", "update", "set", "clear", "copy"))
  expect_length(tsil_store$get(), 0L)
  expect_type(tsil_store$get(), "list")
})

test_that("list stores can be copied and updated", {

  tsilly$set("a", 1L)
  expect_equal(tsil_store$get(), list())
  expect_equal(tsilly$get(), list(a = 1L))

})

test_that("list stores can be updated and cleared", {

  si <- sessionInfo()
  tsil_store$update(si)
  expect_length(tsil_store$get(), length(si))
  tsil_store$clear()
  expect_length(tsil_store$get(), 0L)

})


test_that("nested lists can be created and updated", {
  
  tsilly$set(c("b", "bb", "bbb"), 2L)
  expect_equal(tsilly$get(), list(a = 1L, b = list(bb = list(bbb = 2L))))
  tsilly$set(c("b", "bb", "bbb"), 3L)
  expect_equal(tsilly$get(), list(a = 1L, b = list(bb = list(bbb = 3L))))
  tsilly$update(list(c = list(cc = "by")))
  expect_equal(tsilly$get(), list(a = 1L, b = list(bb = list(bbb = 3L)), c = list(cc = "by")))

})



