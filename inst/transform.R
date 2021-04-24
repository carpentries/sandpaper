library("pegboard")
library("gert")
library("here")

src <- here()
pgap <- pegboard::Lesson$new(src)
# Script to transform the episodes via pegboard with traces
transform <- function(e, out = src) {
  outdir <- fs::path(out, "episodes/")
  message(glue::glue("{e$name}: converting blockquotes to fenced div"))
  e$unblock()
  message(glue::glue("{e$name}: removing Jekyll syntax"))
  e$use_sandpaper()
  message(glue::glue("{e$name}: moving yaml items to body"))
  e$move_questions()
  e$move_objectives()
  e$move_keypoints()
  message(glue::glue("{e$name}: writing output"))
  e$write(outdir, format = "Rmd", edit = FALSE)
}

# function to remove directories
dirdel <- Vectorize({function(d) {
  if (fs::dir_exists(d)) fs::dir_delete(d)
  invisible()
}})

# Read and and transform additional files
rewrite <- function(x, out) {
  ref <- Episode$new()
  ref$unblock()$use_sandpaper()$write(out)
}

set_config <- function(key, value, path = here()) {
  sandpaper::set_dropdown(path, 
    order = value
    write = TRUE,
    folder = key
  ) 
}

# Create a branch for us to work in 
current_branch <- git_branch()
message(glue::glue("switching from {current_branch} to sandpaper")
git_branch_create("sandpaper", ref = "HEAD", checkout = TRUE)

# Create a lesson template and remove the git repository
cfg <- yaml::read_yaml(here("_config.yml"))
tmp <- tempfile()
sandpaper::create_lesson(tmp, name = cfg$title, open = FALSE)
fs::dir_delete(fs::path(tmp, ".git"))
fs::file_delete(fs::path(tmp, c("README.md", "index.md", ".gitignore")))
fs::file_delete(fs::path(tmp, "episodes", "01-introduction.Rmd"))
fs::file_delete(fs::path(tmp, "episodes", "01-introduction.Rmd"))
fs::file_delete(fs::path(tmp, "learners", "Setup.md") 
fs::file_delete(fs::path(tmp, "instructors", "instructor-notes.md")

# Copy the components here
fs::dir_copy(tmp, here(), overwrite = TRUE)

# Modify config file to match as close as possible to the one we have
set_config("life_cycle", cfg$life_cycle)
set_config("contact", cfg$email)
set_config("branch", current_branch)

if (is.null(gh::gh_whoami()) {
  message("Cannot automatically set the following configuration values:\n source: <GITHUB URL>\n carpentry: <CARPENTRY ABBREVIATION>\n\nPlease edit config.yaml to set these values")
} else {
  rmt <- gh::gh_tree_remote()
  url <- glue::glue("https://github.com/{glue::glue_collapse(rmt, '/')}/")
  set_config("source", url)
  set_config("carpentry", 
    switch(rmt, 
      swcarpentry = "swc",
      datacarpentry = "dc",
      librarycarpentry = "lc",
      "carpentries-incubator" = "incubator"
      "cp", # default
  ))  
}


# Transform and write to our episodes folder
purrr::walk(pgap$episodes, ~try(transform(.x)))

# Transform non-episode MD files
rewrite(here("_extras", "design.md"), here("instructors"))
rewrite(here("_extras", "guide.md"), here("instructors"))

rewrite(here("_extras", "discuss.md"), here("learners"))
rewrite(here("_extras", "exercises.md"), here("learners"))
rewrite(here("_extras", "figures.md"), here("learners"))
rewrite(here("reference.md"), here("learners"))
rewrite(here("setup.md"), here("learners"))

rewrite(here("index.md"), here())

# Copy Figures (N.B. this was one of the pain points for the Jekyll lessons: figures lived above the RMarkdown documents)
fs::dir_create(here("episodes", c("fig", "data", "files")))
fs::dir_copy(here("fig"), here("episodes", "fig"))
fs::dir_copy(here("files"), here("episodes", "files"))
fs::dir_copy(here("data"), here("episodes", "data"))
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


