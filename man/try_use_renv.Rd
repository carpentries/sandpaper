% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-renv.R
\name{try_use_renv}
\alias{try_use_renv}
\title{Try to use \code{{renv}}}
\usage{
try_use_renv(force = FALSE)
}
\arguments{
\item{force}{if \code{TRUE}, consent is forced to be TRUE, creating the cache
directory if it did not exist before. Defaults to \code{FALSE}, which gently
inquires for consent.}
}
\value{
a character vector
}
\description{
We use this when sandpaper starts to see if the user has previously consented
to \code{{renv}}. The problem is that \code{\link[renv:consent]{renv::consent()}} throws \code{TRUE} if the user
has consented and an error if it has not :(
}
\details{
This function wraps \code{renv::consent()} in a callr function and transforms the
error into \code{FALSE}. It sets the \code{sandpaper.use_renv} variable to the value of
that check and then returns the full text of the output if \code{FALSE} (this is
the WELCOME message that's given when someone uses \code{{renv}} for the first time)
and the last line of output if \code{TRUE} (a message either that a directory has
been created or that consent has already been provided.)
}
\keyword{internal}
