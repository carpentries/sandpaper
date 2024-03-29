% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/move_episode.R
\name{move_episode}
\alias{move_episode}
\title{Move an episode in the schedule}
\usage{
move_episode(ep = NULL, position = NULL, write = FALSE, path = ".")
}
\arguments{
\item{ep}{the name of a draft episode or the name/number of a published
episode to move.}

\item{position}{the position in the schedule to move the episode. Valid
positions are from 0 to the number of episodes (+1 for drafts). A value
of 0 indicates that the episode should be removed from the schedule.}

\item{write}{defaults to \code{FALSE}, which will show the potential changes.
If \code{TRUE}, the schedule will be modified and written to \code{config.yaml}}

\item{path}{the path to the lesson (defaults to the current working directory)}
}
\description{
If you need to move a single episode, this function gives you a programmatic
or interactive interface to accomplishing this task, whether you need to add
and episode, draft, or remove an episode from the schedule.
}
\examples{
if (interactive() || Sys.getenv("CI") != "") {
  tmp <- tempfile()
  create_lesson(tmp)
  create_episode_md("getting-started", path = tmp, open = FALSE)
  create_episode_rmd("plotting", path = tmp, open = FALSE)
  create_episode_md("experimental", path = tmp, add = FALSE, open = FALSE)
  set_episodes(tmp, c("getting-started.md", "introduction.Rmd", "plotting.Rmd"),
    write = TRUE)

  # Default episode order is alphabetical, we can use this to nudge episodes
  get_episodes(tmp)
  move_episode("introduction.Rmd", 1L, path = tmp) # by default, it shows you the change
  move_episode("introduction.Rmd", 1L, write = TRUE, path = tmp) # write the results
  get_episodes(tmp)

  # Add episodes from the drafts
  get_drafts(tmp)
  move_episode("experimental.md", 2L, path = tmp) # view where it will live
  move_episode("experimental.md", 2L, write = TRUE, path = tmp)
  get_episodes(tmp)

  # Unpublish episodes by setting position to zero
  move_episode("experimental.md", 0L, path = tmp) # view the results
  move_episode("experimental.md", 0L, write = TRUE, path = tmp)
  get_episodes(tmp)

  # Interactively select the position where the episode should go by omitting
  # the position argument
  if (interactive()) {
    move_episode("experimental.md", path = tmp)
  }
}
}
\seealso{
\code{\link[=create_episode]{create_episode()}}, \code{\link[=set_episodes]{set_episodes()}}, \code{\link[=get_drafts]{get_drafts()}}, \code{\link[=get_episodes]{get_episodes()}}
}
