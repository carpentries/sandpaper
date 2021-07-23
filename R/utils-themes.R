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
