#' Internal cache for storing pre-computed lesson objects
#'
#' @description
#' A storage cache for [pegboard::Lesson] objects and other pre-computed items
#' for use by other internal functions while `{sandpaper}` is working.
#'
#' @section Lesson Object Storage:
#'
#'  `this_lesson()` will return a [pegboard::Lesson] object if it has
#'   previously been stored. There are three values that are cached:
#'
#'   - `.this_lesson` a [pegboard::Lesson] object
#'   - `.this_diff` a charcter vector from [gert::git_diff_patch()]
#'   - `.this_status` a data frame from [gert::git_status()]
#'   - `.this_commit` the hash of the most recent commit
#'
#'   The function `this_lesson()` first checks if `.this_diff` is different than
#'   the output of [gert::git_diff_patch()], then checks if there are any
#'   changes to [gert::git_status()], and then finally checks if the commits are
#'   identical. If there are differences or the values are not previously
#'   cached, the lesson is loaded into memory, otherwise, it is fetched from the
#'   previously stored lesson.
#'
#'   The storage cache is in a global package object called `.store`, which is
#'   initialised when `{sandpaper}` is loaded via `.lesson_store()`
#'
#'   If there have been no changes git is aware of, the lesson remains the same.
#'
#' @section Pre-Computed Object Storage:
#'
#'  A side-effect of `this_lesson()` is that it will also initialise
#'  pre-computed objects that pertain to the lesson itself. These are
#'  initialised via `set_globals()`. These storage objects are:
#'
#'    - `.resources`: a list of markdown resources for the lesson derived from
#'        `get_resource_list()` via `set_resource_list()`
#'    - `this_metadata`: metadata with template for including in the pages.
#'        initialised in `initialise_metadata()` via `set_globals()`
#'    - `learner_globals`: variables for the learner version of the pages
#'        initialised in `set_globals()`
#'    - `instructor_globals`: variables for the instructor version of the pages
#'        initialised in `set_globals()`
#'
#' @param path a path to the current lesson
#' @rdname lesson_storage
#' @keywords internal
#' @examples
#' tmp <- tempfile()
#' create_lesson(tmp, open = FALSE, rmd = FALSE)
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
this_lesson <- function(path) {
  if (.store$valid(path)) .store$get() else .store$set(path)
}

#' @rdname lesson_storage
clear_this_lesson <- function() .store$clear()

#' @rdname lesson_storage
set_this_lesson <- function(path) .store$set(path)

#' @rdname lesson_storage
set_resource_list <- function(path) {
  .resources$set(key = NULL, get_resource_list(path))
}

#' @rdname lesson_storage
clear_resource_list <- function(path) {
  .resources$clear()
}

# LESSON STORAGE GENERATORS ----------------------------------------------------

#' List Storage Generator
#'
#' This is a function that will generate an object that can serve as persistant
#' storage for pre-computed values. Each object contains a list called
#' `.this_list` embedded within the enviroment it was created in.
#'
#' @return a list with five functions the all operate on the internal
#'  `.this_list` list object:
#'  - `get()` returns the value of `.this_list`
#'  - `update(value)` updates `.this_list` with a modified list `value`. Useful
#'    for adding several pieces of information at once.
#'  - `set(key, value)` sets a given `key` (vector, with each element
#'     representing a level of nesting) to a particular value (can be a vector
#'     or list). If the `key` is `NULL`, `.this_list` is replaced with `value`
#'  - `clear()` sets `.this_list` to `NULL`
#'  - `copy()` creates an independent copy of the object for modification.
#'
#' @keywords internal
#' @examples
#' if (FALSE) {
#'   # note: asNamespace() gives access to internal functions. This is for
#'   # demonstration purposes only. There is no guarantee for these functions to
#'   # work.
#'   global_list <- asNamespace("sandpaper")$.list_store()
#'   global_list$set(key = NULL, list(a = 1, b = list(2)))
#'   global_list$set(key = "c", "three")
#'   global_list$get()
#'   global_list$update(list(c = "THREE", d = global_list$get()))
#'   global_list$get()
#' }
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

#' Internal Global Lesson Storage Generator
#'
#' This function will generate an object store that will contain and update a
#' lesson object based on the status of the git repository
#'
#' @return a list with four functions that operate on a supplied path string
#'
#'  - `get()` returns `.this_lesson` (as described in [this_lesson()])
#'  - `set(path)` sets `.this_lesson` and its git statuses from the lesson in
#'    `path`. This also sets `set_globals()` and `set_resource_list()`.
#'  - `valid(path)` uses `path` to validate if a lesson is identical to the
#'    stored lesson from its git status. Returns `TRUE` if it is identical and
#'    `FALSE` if it is not
#'  - `clear()` resets all global variables.
#'
#' @keywords internal
#' @seealso [.list_store()] for a generic list implementation and
#' [this_lesson()] for details of the implementation of this generator in
#' sandpaper
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
      # set the globals stored in this object
      .this_diff   <<- gert::git_diff(repo = path)$patch
      .this_status <<- gert::git_status(repo = path)
      .this_commit <<- gert::git_log(repo = path, max = 1L)$commit
      .this_lesson <<- pegboard::Lesson$new(path, jekyll = FALSE)
      # set the global storage for `{varnish}` so that we do not have to recompute
      # things like the sidebar
      set_globals(path)
      # kludge to make sure overview status is accurate
      this_metadata$set("overview", .this_lesson$overview)
      # resource list of files for the lesson via `get_resource_list()`
      set_resource_list(path)
      instructor_globals$set("syllabus",
        create_syllabus(.resources$get()[["episodes"]], .this_lesson, path)
      )
      learner_globals$set("overview", .this_lesson$overview)
      instructor_globals$set("overview", .this_lesson$overview)
      invisible(.this_lesson)
    },
    clear = function() {
      .this_diff   <<- NULL
      .this_lesson <<- NULL
      .this_commit <<- NULL
      clear_globals()
      clear_resource_list()
    }
  )
}

#nocov start
create_template_check <- function() {
  .varnish_store <- NULL
  list(
    valid = function() {
      path <- system.file("pkgdown/templates", package = "varnish")
      res  <- tools::md5sum(list.files(path, full.names = TRUE))
      identical(res, .varnish_store)
    },
    set = function() {
      path <- system.file("pkgdown/templates", package = "varnish")
      .varnish_store <<- tools::md5sum(list.files(path, full.names = TRUE))
    },
    clear = function() {
      .varnish_store <<- NULL
    }
  )
}

template_check <- create_template_check()
#nocov end


#nocov start
# GLOBAL LESSON STORAGE --------------------------------------------------------
# all of these resources are intended to be relevant between when build_lesson
# starts and when it exits. These are not intended to be valid between those
# times.

# storage for the pegboard::Lesson object
.store <- .lesson_store()

# storage for get_resource_list()
.resources <- .list_store()

# storage for pre-processed template pages
.html <- .list_store()

# storage for global variables for the lesson site (those that get passed on to
# `{varnish}`)
instructor_globals <- .list_store()
learner_globals <- .list_store()

# storage for the metadata
this_metadata <- .list_store()
#nocov end
