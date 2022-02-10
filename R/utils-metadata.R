create_metadata_jsonld <- function(path = ".", ...) {
  initialise_metadata(path)
  l <- list(...)
  meta <- this_metadata$copy()
  on.exit(rm(meta))
  meta$update(l)
  fill_metadata_template(meta)
}


fill_metadata_template <- function(meta) {
  local_meta <- meta$get()
  json <- local_meta[["metadata_template"]]
  json <- whisker::whisker.render(json, local_meta)
  json
}

metadata_url <- function(cfg) {
  url <- cfg$url %||% make_github_url(cfg$source)
  if (endsWith(url, "/")) url else paste0(url, "/")
}

initialise_metadata <- function(path = ".") {
  if (length(this_metadata$get()) == 0) {
    cfg <- get_config(path)
    this_metadata$set("metadata_template", readLines(template_metadata()))
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


