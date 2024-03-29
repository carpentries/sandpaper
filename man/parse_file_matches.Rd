% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-paths-source.R
\name{parse_file_matches}
\alias{parse_file_matches}
\title{Subset file matches to the order they appear in the config file}
\usage{
parse_file_matches(reality, hopes = NULL, warn = FALSE, subfolder)
}
\arguments{
\item{reality}{a list of paths that exist in the lesson}

\item{hopes}{a list of files in the order they should appear in the lesson}

\item{warn}{a boolean. If \code{TRUE} and the \code{sandpaper.show_draft} option is
set to TRUE, then the files that are not in \code{hopes} are shown to the
screen as drafts}

\item{subfolder}{a character. The folder where we should find the files in
\code{hopes}. This is only used for creating an error message.}
}
\value{
a character vector of \code{reality} subset in the order of \code{hopes}
}
\description{
Subset file matches to the order they appear in the config file
}
\examples{
# setup ----------------------------------------------------
#
# NOTE: we need to define our namespace here because using `:::`
# in example calls is illegal.
snd <- asNamespace("sandpaper")
print(need <- c("a", "bunch", "of", "silly", "files"))
print(exists <- fs::path("path", "to", sample(need)))

# Rearrange files ------------------------------------------
snd$parse_file_matches(reality = exists, hopes = need,
  subfolder = "episodes")

# a subset of files ----------------------------------------
snd$parse_file_matches(reality = exists,
  hopes = need[4:5], subfolder = "episodes")

# a subset of files with a warning -------------------------
op <- getOption("sandpaper.show_draft")
options(sandpaper.show_draft = TRUE)
on.exit(options(sandpaper.show_draft = op))
snd$parse_file_matches(reality = exists,
  hopes = need[-(4:5)], warn = TRUE, subfolder = "episodes")

# files that do not exist give an error --------------------
try(snd$parse_file_matches(reality = exists,
  hopes = c("these", need[4:5]), subfolder = "episodes"))
}
\keyword{internal}
