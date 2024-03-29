% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_aio.R
\name{make_aio_section}
\alias{make_aio_section}
\title{Make a section and place it inside the All In One page}
\usage{
make_aio_section(name, contents, parent)
}
\arguments{
\item{name}{the name of the section, prefixed with \verb{episode-}}

\item{contents}{the episode contents from \code{\link[=get_content]{get_content()}}}

\item{parent}{the parent div of the AiO page.}
}
\value{
the section that was added to the parent
}
\description{
When an episode needs to be added to the AiO, this will insert the XML nodes
from the episode contents in its own section inside the All In One page.
}
\examples{
if (FALSE) {
  lsn <- "/path/to/lesson"
  pkg <- pkgdown::as_pkgdown(fs::path(lsn, "site"))

  # read in the All in One page and extract its content
  aio <- get_content("aio", content = "self::*", pkg = pkg)
  episode_content <- get_content("01-introduction", pkg = pkg)
  make_aio_section("aio-01-introduction",
    contents = episode_content, parent = aio
  )
}
}
\seealso{
\code{\link[=build_aio]{build_aio()}}, \code{\link[=get_content]{get_content()}}
}
\keyword{internal}
