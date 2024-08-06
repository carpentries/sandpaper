#' Create a carpentries lesson
#'
#' This will create a boilerplate directory structure for a Carpentries lesson
#' and initialize a git repository.
#'
#' @param path the path to the new lesson folder
#' @param name the name of the lesson. If not provided, the folder name will be used.
#' @param rmd logical indicator if the lesson should use R Markdown (`TRUE`,
#'   default), or if it should use Markdown (`FALSE`). Note that lessons can be
#'   converted to use R Markdown at any time by adding a file with the `.Rmd`
#'   file extension in the lesson.
#' @param rstudio create an RStudio project (defaults to if RStudio exits)
#' @param open if interactive, the lesson will open in a new editor window.
#'
#' @export
#' @return the path to the new lesson
#' @examples
#' tmp <- tempfile()
#' on.exit(unlink(tmp))
#' lsn <- create_lesson(tmp, name = "This Lesson", open = FALSE)
#' lsn
create_lesson <- function(path, name = fs::path_file(path), rmd = TRUE, rstudio = rstudioapi::isAvailable(), open = rlang::is_interactive()) {

  path <- fs::path_abs(path)
  id <- cli::cli_status("{cli::symbol$arrow_right} Creating Lesson in {.file {path}}...")
  init_source_path(path)

  cli::cli_status_update("{cli::symbol$arrow_right} Creating Lesson folder structure...")

  fs::dir_create(fs::path(path, "episodes"))
  fs::dir_create(fs::path(path, "episodes", "data"))
  fs::dir_create(fs::path(path, "episodes", "files"))
  fs::dir_create(fs::path(path, "episodes", "fig"))
  fs::dir_create(fs::path(path, "instructors"))
  fs::dir_create(fs::path(path, "learners"))
  fs::dir_create(fs::path(path, "profiles"))
  fs::file_create(fs::path(path, "README.md"))

  cli::cli_status_update("{cli::symbol$arrow_right} Copying file templates ...")
  copy_template("gitignore", path, ".gitignore")
  copy_template("conduct", path, "CODE_OF_CONDUCT.md")
  copy_template("license", path, "LICENSE.md")
  copy_template("contributing", path, "CONTRIBUTING.md")
  copy_template("citation", path, "CITATION.cff")
  copy_template("setup", fs::path(path, "learners"), "setup.md")
  copy_template("index", path, "index.md")
  copy_template("links", path, "links.md")
  copy_template("placeholder", fs::path(path, "instructors"),
    name = "instructor-notes.md",
    values = list(title = "Instructor Notes", heading = NULL))
  copy_template("placeholder", fs::path(path, "profiles"),
    name = "learner-profiles.md",
    values = list(title = NULL, heading = NULL))
  copy_template("placeholder", fs::path(path, "learners"),
    name = "reference.md",
    values = c(title = "Reference", heading = "Glossary"))

  cli::cli_status_update("{cli::symbol$arrow_right} Generating {.file config.yaml} ...")
  account <- tryCatch(gh::gh_whoami()$login, error = function(e) "carpentries")
  copy_template("config", path, "config.yaml",
    values = list(
      title      = if (is.null(match.call()$name)) "Lesson Title" else siQuote(name),
      carpentry  = "incubator",
      created    = as.character(Sys.Date()),
      life_cycle = "pre-alpha",
      license    = "CC-BY 4.0",
      source     = glue::glue("https://github.com/{account}/{basename(path)}"),
      branch     = get_default_branch(),
      contact    = "team@carpentries.org",
      NULL
    )
  )

  cli::cli_status_update("{cli::symbol$arrow_right} Generating {.file README.md} ...")
  create_lesson_readme(name, path)
  create_site(path)

  cli::cli_status_update("{cli::symbol$arrow_right} Creating first episode ...")
  ep <- create_episode("introduction", ext = if (rmd) "Rmd" else "md", path = path, open = FALSE)
  cli::cli_alert_success("First episode created in {.file {ep}}")

  if (rstudio) {
    cli::cli_status_update("{cli::symbol$arrow_right} Creating RStudio project ...")
    usethis::with_project(path, usethis::use_rstudio())
    gi <- readLines(fs::path(path, ".gitignore"))
    writeLines(gi[-length(gi)], fs::path(path, ".gitignore"))
  }

  cli::cli_status_update("{cli::symbol$arrow_right} Inserting GitHub workflows ...")
  update_github_workflows(path)

  has_consent <- rmd && getOption("sandpaper.use_renv")
  if (has_consent) {
    cli::cli_status_update("{cli::symbol$arrow_right} Managing Dependencies ...")
    manage_deps(path, snapshot = TRUE)
  }

  cli::cli_status_update("{cli::symbol$arrow_right} Committing ...")
  gert::git_add(".", repo = path)
  gert::git_commit(message = "Initial commit [via `{sandpaper}`]", repo = path)
  enforce_main_branch(path)
  reset_git_user(path)

  cli::cli_alert_success("Lesson successfully created in {.file {path}}")
  if (open) {
    if (usethis::proj_activate(path)) {
      on.exit()
    }
  }


  cli::cli_status_clear()
  invisible(return(path))

}
