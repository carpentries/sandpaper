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
#'   The storage cache is in a global package object called `.store`, which is
#'   initialised when {sandpaper} is loaded via `.lesson_store()`
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

#' @rdname lesson_storage
set_resource_list <- function(path) {
  .resources$set(key = NULL, get_resource_list(path))
}

#' @rdname lesson_storage
clear_resource_list <- function(path) {
  .resources$clear()
}

# generator for the 
.lesson_store <- function() {
  .this_diff <- NULL
  .this_status <- NULL
  .this_lesson <- NULL
  .this_commit <- NULL

  list(
    get = function() {
      invisible(.this_lesson)
    },
    valid = function(path) {
      identical(.this_diff, gert::git_diff(repo = path)$patch) &&
        identical(.this_status, gert::git_status(repo = path)) &&
        identical(.this_commit, gert::git_log(repo = path, max = 1L)$commit)
    },
    set = function(path) {
      .this_diff   <<- gert::git_diff(repo = path)$patch
      .this_status <<- gert::git_status(repo = path)
      .this_commit <<- gert::git_log(repo = path, max = 1L)$commit
      .this_lesson <<- pegboard::Lesson$new(path, jekyll = FALSE)
      invisible(.this_lesson)
    },
    clear = function() {
      .this_diff   <<- NULL
      .this_lesson <<- NULL
      .this_commit <<- NULL
    }
  )
}

# create a global list of things
.list_store <-  function() {
  .this_list <- list()
  structure(list(
    get = function() return(.this_list),
    update = function(value) {
      .this_list <<- modifyList(.this_list, value)
    },
    set = function(key = NULL, value) {
      if (is.null(key)) {
        .this_list <<- value
      } else if (length(key) == 1) {
        .this_list[[key]] <<- value
      } else {
        l <- list()
        for (i in seq(key)) {
          l[[key[seq(i)]]] <- list()
        }
        l[[key]] <- value
        if (length(.this_list)) {
          .this_list <<- modifyList(.this_list, l)
        } else {
          .this_list <<- l
        }
      }
      invisible(.this_list)
    },
    clear = function(key = NULL) {
      if (is.null(key)) {
        .this_list <<- NULL
      } else {
        .this_list[[key]] <<- NULL
      }
    },
    copy = function() {
      new <- .list_store()
      new$set(key = NULL, .this_list)
      return(new)
    }
  ), class = "list-store")
}

#nocov start
# all of these resources are intended to be relevant between when build_lesson
# starts and when it exits. These are not intended to be valid between those
# times.

# storage for the pegboard::Lesson object
.store <- .lesson_store()

# storage for get_resource_list()
.resources <- .list_store()

# storage for global variables for the lesson site (those that get passed on to
# {varnish})
instructor_globals <- .list_store()
learner_globals <- .list_store()

# storage for the metadata
this_metadata <- .list_store()
#nocov end
