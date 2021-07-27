remove_cli_decoration <- function(msg) {
  msg <- gsub("[}] ", "` ", msg)
  gsub(" [{][^ ]*[ ]?", " `", msg)
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
