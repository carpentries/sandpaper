.metadata_store <-  function() {
  .metadata <- list()
  list(
    get = function() return(.metadata),
    update = function(value) {
      .metadata <<- modifyList(.metadata, value)
    },
    set = function(key = NULL, value) {
      if (is.null(key)) {
        .metadata <<- value
      } else if (length(key) == 1) {
        .metadata[[key]] <<- value
      } else {
        l <- list()
        for (i in seq(key)) {
          l[[key[seq(i)]]] <- list()
        }
        l[[key]] <- value
        if (length(.metadata)) {
          .metadata <<- modifyList(.metadata, l)
        } else {
          .metadata <<- l
        }
      }
      invisible(.metadata)
    },
    clear = function(key = NULL) {
      if (is.null(key)) {
        .metadata <<- NULL
      } else {
        .metadata[[key]] <<- NULL
      }
    },
    copy = function() {
      new <- .metadata_store()
      new$set(key = NULL, .metadata)
      return(new)
    }
  )
}
this_metadata <- .metadata_store()

create_metadata_jsonld <- function(path = ".", ...) {
  initialise_metadata(path)
  json <- readLines(template_metadata())
  l <- list(...)
  meta <- this_metadata$copy()
  meta$update(l)
  json <- whisker::whisker.render(json, meta$get())
  rm(meta)
  json
}

metadata_url <- function(cfg) {
  url <- cfg$url %||% make_github_url(cfg$source)
  if (endsWith(url, "/")) url else paste0(url, "/")
}

initialise_metadata <- function(path = ".") {
  if (length(this_metadata$get()) == 0) {
    cfg <- get_config(path)
    this_metadata$set("pagetitle", cfg$title)
    this_metadata$set("url", metadata_url(cfg))
    this_metadata$set("keywords", cfg$keywords)
    created <- cfg$created %||% tail(gert::git_log(max = 1e6, repo = path)$time, 1)
    this_metadata$set(c("date", "created"), format(as.Date(created), "%F"))
    # TODO: implement custom DESCRIPTION
    # For the Description, it would be good to take this from an ABOUT page
    # where the description paragraph can be found under the Description header
  }
  this_metadata$set(c("date", "modified"), format(Sys.Date(), "%F"))
  this_metadata$set(c("date", "published"), format(Sys.Date(), "%F"))
}
