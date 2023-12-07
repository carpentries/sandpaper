ci_group <- function(group = "Group") {
  cli::cat_line(glue::glue("::group::{group}"))
}
describe_progress <- function(..., quiet = FALSE) {
  if (!quiet) cli::cli_rule(cli::style_bold(...))
}

sandpaper_cli_theme <- function() {
  list(
    ul = list(
      "list-style-type" = function() "-"
      ),
    ".alert-warning" = list(
      before = function() paste0(cli::col_yellow(cli::symbol$cirle), " ")
      ),
    ".alert-danger" = list(
      before = function() paste0(cli::col_red("!"), " ")
      ),
    ".alert-success" = list(
      before = function() paste0(cli::col_cyan(cli::symbol$circle_filled), " ")
      ),
    ".alert-suggestion" = list(
      "font-style" = "italic"
      ),
    "span.renvmessage" = list(
      "background-color" = "#FAE3B4",
      "color" = "#000000",
      "font-style" = "bold"
      ),
    NULL
  )
}

warn_schedule <- function() {
  msg  <- "No schedule set, using Rmd files in {.file episodes/} directory."
  msg2 <- "To remove this message, define your schedule in {.file config.yaml}"
  msg3 <- "or use {.code set_episodes()} to generate it."
  thm <- cli::cli_div(theme = sandpaper_cli_theme())
  cli::cli_alert_info(msg)
  cli::cli_alert(cli::style_dim(paste(msg2, msg3)), class = "alert-suggestion")
  cli::cli_end(thm)
}

warn_no_language <- function(lang) {
  thm <- cli::cli_div(theme = sandpaper_cli_theme())
  wmsg <- "{.code {siQuote(lang)}} is not a language that has been defined in The Workbench."
  cli::cli_alert_warning(wmsg)
  amsg1 <- "Use {.code known_languages()} to see a list of known languages"
  cli::cli_alert_info(cli::style_dim(amsg1), class = "alert-suggestion")
  amsg2 <- c("To add a new language, consult {.code vignette('translations', package = 'sandpaper')}")
  cli::cli_alert_info(cli::style_dim(amsg2), class = "alert-suggestion")

  cli::cli_end(thm)
}

show_changed_yaml <- function(sched, order, yaml, what = "episodes") {

  # display for the user to distinguish what was added and what was taken
  removed <- sched %nin% order
  added   <- order %nin% sched
  thm <- cli::cli_div(theme = sandpaper_cli_theme())
  on.exit(cli::cli_end(thm))
  pid <- cli::cli_par()
  cli::cli_text("{what}:")
  lid <- cli::cli_ul()
  for (i in seq(order)) {
    if (added[i]) {
      thing <- cli::style_bold(cli::col_cyan(order[i]))
    } else {
      thing <- order[i]
    }
    cli::cli_li("{thing}")
  }
  cli::cli_end(lid)
  cli::cli_end(pid)
  if (any(removed)) {
    cli::cli_rule("Removed {what}")
    lid <- cli::cli_ul()
    the_removed <- sched[removed]
    for (i in the_removed) {
      cli::cli_li("{cli::style_italic(i)}")
    }
    cli::cli_end(lid)
  }

}

show_write_hint <- function(the_call = NULL, write = "write", additions = list(), which = 1) {
  if (is.null(the_call)) {
    return(invisible(the_call))
  }
  should_write <- the_call[[write]]
  if (identical(should_write, TRUE)) {
    return(invisible(the_call))
  }
  the_call[[write]] <- TRUE
  for (a in names(additions)) {
    the_call[[a]] <- additions[[a]]
  }
  cll <- gsub("\\s+", " ", paste(utils::capture.output(the_call), collapse = ""))
  cli::cli_rule()
  cli::cli_alert_info("To save this configuration, use\n\n{cll}")
  return(invisible(the_call))
}

message_default_draft <- function(subfolder) {
  message_no_draft(subfolder, " (config.yaml empty)")
}

message_no_draft <- function(subfolder, append = "") {
  thm <- cli::cli_div(theme = sandpaper_cli_theme())
  on.exit(cli::cli_end(thm), add = TRUE)
  cli::cli_alert_info("All files in {.file {subfolder}/} published{append}")
}

message_draft_files <- function(hopes, real_files, subfolder) {
  thm <- cli::cli_div(theme = sandpaper_cli_theme())
  on.exit(cli::cli_end(thm), add = TRUE)
  dreams <- fs::path(subfolder, real_files[real_files %nin% hopes])
  if (length(dreams)) {
    cli::cli_alert_info(
      "{.emph Files are in draft: {.file {dreams}}}"
    )
  }
}

message_package_cache <- function(msg) {
  our_lines <- grep("(renv maintains a local cache)|^(This path can be customized)", msg)
  RENV_MESSAGE <- msg[our_lines[1]:our_lines[2]]
  RENV_MESSAGE <- paste(RENV_MESSAGE, collapse = "\f")
  txt <- readLines(system.file("templates", "consent-form.txt", package = "sandpaper"))
  txt <- paste(txt, collapse = "\n")
  cli::cli_div(theme = sandpaper_cli_theme())
  cli::cli_h1("Caching Build Packages for Generated Content")
  cli::cli_text(txt)
  cli::cli_rule("Enter your selection or press 0 to exit")
  options <- c(
    glue::glue("{cli::style_bold('Yes')}, please use the package cache (recommended)"),
    glue::glue("{cli::style_bold('No')}, I want to use my default library")
  )
}

error_missing_config <- function(hopes, reality, subfolder) {
  thm <- cli::cli_div(theme = sandpaper_cli_theme())
  on.exit(cli::cli_end(thm), add = TRUE)
  broken_dreams <- hopes %nin% reality
  cli::cli_text("{subfolder}:")
  lid <- cli::cli_ul()
  for (i in seq(hopes)) {
    if (broken_dreams[i]) {
      cli::cli_li("{cli::symbol$cross} {.strong {hopes[i]}}")
    } else {
      cli::cli_li("{.file {hopes[i]}}")
    }
  }
  cli::cli_end(lid)
  cli::cli_abort(c(
    "All files in {.file config.yaml} must exist",
    "*" = "Files marked with {cli::symbol$cross} are not present"
  ))
}
