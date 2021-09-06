library("pegboard")
library("gert")
library("here")

src <- here()
pgap <- pegboard::Lesson$new(src)
# Script to transform the episodes via pegboard with traces
transform <- function(e, out = src) {
  outdir <- fs::path(out, "episodes/")
  cli::cat_rule(fs::path_rel(e$name, out)) # -----------------------------------
  cli::cli_process_start(glue::glue(" converting blockquotes to fenced div"))
  e$unblock()
  cli::cli_process_done()

  cli::cli_process_start(glue::glue("removing Jekyll syntax"))
  e$use_sandpaper()
  cli::cli_process_done()

  cli::cli_process_start(glue::glue("moving yaml items to body"))
  e$move_questions()
  e$move_objectives()
  e$move_keypoints()
  cli::cli_process_done()

  cli::cli_process_start(glue::glue("writing output"))
  e$write(outdir, format = "Rmd", edit = FALSE)
  cli::cli_process_done()
}

# function to remove directories
dirdel <- Vectorize({function(d) {
  if (fs::dir_exists(d)) fs::dir_delete(d)
  invisible()
}})

# Read and and transform additional files
rewrite <- function(x, out) {
  ref <- Episode$new(x)
  ref$unblock()$use_sandpaper()$write(out)
}

set_config <- function(key, value, path = here()) {
  sandpaper::set_dropdown(path,
    order = value,
    write = TRUE,
    folder = key
  )
}

# Create a branch for us to work in
current_branch <- git_branch()
message(glue::glue("switching from {current_branch} to sandpaper"))
if (git_branch_exists("sandpaper")) git_branch_delete("sandpaper")
git_branch_create("sandpaper", ref = "HEAD", checkout = TRUE)

# Create a lesson template and remove the git repository
cfg <- yaml::read_yaml(here("_config.yml"))
tmp <- tempfile()
sandpaper::create_lesson(tmp, name = cfg$title, open = FALSE)
# appending our gitignore file
file.append(".gitignore", fs::path(tmp, ".gitignore"))
fs::dir_delete(fs::path(tmp, ".git"))
fs::file_delete(fs::path(tmp, c("README.md", "index.md", ".gitignore")))
fs::file_delete(fs::path(tmp, "episodes", "01-introduction.Rmd"))
fs::file_delete(fs::path(tmp, "learners", "setup.md"))
fs::file_delete(fs::path(tmp, "instructors", "instructor-notes.md"))

# Copy the components here
message(glue::glue("copying the sandpaper template on top of the current files"))
fs::dir_copy(tmp, here(), overwrite = TRUE)

# Modify config file to match as close as possible to the one we have
message("setting the configuration parameters in config.yaml")
set_config("title", cfg$title)
set_config("life_cycle", cfg$life_cycle)
set_config("contact", cfg$email)
set_config("branch", current_branch)

if (length(gert::git_remote_list()) == 0) {
  message("Cannot automatically set the following configuration values:\n source: <GITHUB URL>\n carpentry: <CARPENTRY ABBREVIATION>\n\nPlease edit config.yaml to set these values")
} else {
  rmt <- gert::git_remote_list()
  i <- if (any(i <- rmt$name == "upstream")) which(i) else 1L
  url <- rmt$url[[i]]
  rmt <- gh:::github_remote_parse(rmt$url[[i]])$username
  set_config("source", url)
  set_config("carpentry",
    switch(rmt,
      swcarpentry = "swc",
      datacarpentry = "dc",
      librarycarpentry = "lc",
      "carpentries-incubator" = "incubator",
      "cp" # default
  ))
}


# Transform and write to our episodes folder
purrr::walk(pgap$episodes, ~try(transform(.x)))

# Transform non-episode MD files
rewrite(here("_extras", "design.md"), here("instructors"))
# NOTE: quotation is throwing things off here :(

rewrite(here("_extras", "guide.md"), here("instructors"))

rewrite(here("_extras", "discuss.md"), here("learners"))
rewrite(here("_extras", "exercises.md"), here("learners"))
rewrite(here("_extras", "figures.md"), here("learners"))
rewrite(here("reference.md"), here("learners"))
rewrite(here("setup.md"), here("learners"))

rewrite(here("index.md"), here())

# Copy Figures (N.B. this was one of the pain points for the Jekyll lessons: figures lived above the RMarkdown documents)
fs::dir_create(here("episodes", c("fig", "data", "files")))
fs::dir_copy(here("fig"), here("episodes"))
fs::dir_copy(here("files"), here("episodes"))
fs::dir_copy(here("data"), here("episodes"))
fs::dir_delete(here(c("data", "fig")))

# Remove unnecessary dirs
dirdel(c(
  "_episodes",
  "_episodes_rmd",
  "_extras",
  "_includes",
  "_layouts",
  "assets",
  "bin",
  "code",
  "data",
  "files",
  "fig"
))


