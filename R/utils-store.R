#' Internal cache for storing lesson objects
#'
#' @description
#' A storage cache for [pegboard::Lesson] objects that works across the
#' functions while {sandpaper} is working. 
#'
#' @details `this_lesson()` will return a [pegboard::Lesson] object if it has
#'   previously been stored. There are three values that are cached:
#'   
#'   - `.this_lesson` a [pegboard::Lesson] object
#'   - `.this_diff` a charcter vector from [gert::git_diff_patch()]
#'   - `.this_status` a data frame from [gert::git_status()]
#'
#'   The function `this_lesson()` first checks if `.this_diff` is different than
#'   the output of [gert::git_diff_patch()] and then check if there are any
#'   changes to [gert::git_status()]. If there are no differences or the values
#'   are not previously cached, the lesson is loaded into memory.
#'
#'   If there have been no changes git is aware of, the lesson remains the same.
#' @param path a path to the current lesson 
#' @rdname lesson_storage
#' @keywords internal
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE)
#' # Read the lesson into cache
#' system.time(sandpaper:::this_lesson(tmp)) 
#' system.time(sandpaper:::this_lesson(tmp)) # less time to read in once cached
#' l <- sandpaper:::this_lesson(tmp)
#' l
#' # clear the cache
#' sandpaper:::clear_this_lesson()
#' system.time(sandpaper:::this_lesson(tmp)) # have to re-read the lesson
#' system.time(sandpaper:::this_lesson(tmp)) 
#' unlink(tmp)
set_this_lesson <- function(path) .store$set(path)

#' @rdname lesson_storage
clear_this_lesson <- function() .store$clear()

#' @rdname lesson_storage
this_lesson <- function(path) {
  if (.store$valid(path)) .store$get() else .store$set(path)
}
.lesson_store <- function() {
  .this_diff <- NULL
  .this_status <- NULL
  .this_lesson <- NULL

  list(
    get = function() {
      invisible(.this_lesson)
    },
    valid = function(path) {
      identical(.this_diff, gert::git_diff(repo = path)$patch) &&
        identical(.this_status, gert::git_status(repo = path))
    },
    set = function(path) {
      .this_diff   <<- gert::git_diff(repo = path)$patch
      .this_status <<- gert::git_status(repo = path)
      .this_lesson <<- pegboard::Lesson$new(path, jekyll = FALSE)
      invisible(.this_lesson)
    },
    clear = function() {
      .this_diff   <<- NULL
      .this_lesson <<- NULL
    }
  )
}
#nocov start
.store <- .lesson_store()
#nocov end
