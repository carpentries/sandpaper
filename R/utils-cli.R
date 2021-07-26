remove_cli_decoration <- function(msg) {
  msg <- gsub("[}] ", "` ", msg)
  gsub(" [{][^ ]*[ ]?", " `", msg)
}

sandpaper_cli_theme <- function() {
  list(
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
