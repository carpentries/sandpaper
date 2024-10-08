% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_html.R
\name{build_html}
\alias{build_html}
\title{Build instructor and learner HTML page}
\usage{
build_html(
  template = "chapter",
  pkg,
  nodes,
  global_data,
  path_md,
  quiet = TRUE
)
}
\arguments{
\item{template}{the name of the \code{{varnish}} template to use. Defaults to
"chapter"}

\item{pkg}{an object created from  \code{\link[pkgdown:as_pkgdown]{pkgdown::as_pkgdown()}}}

\item{nodes}{an \code{xml_document} object. \code{nodes} will be a list of two
\code{xml_documents}; one for instructors and one for learners so that the
instructors have the schedule available to them. If both the instructor
and learner page, it will be a single \code{xml_document} object.}

\item{global_data}{a list store object that contains copies of the global
variables for the page, including metadata, navigation, and variables for
the \code{{varnish}} templates.}

\item{path_md}{the path (absolute, relative, or filename) the current
markdown file being processed.}

\item{quiet}{This parameter is passed to \code{\link[pkgdown:render_page]{pkgdown::render_page()}} and will
print the progress if \code{TRUE} (default).}
}
\value{
\code{TRUE} if the page was built and \code{NULL} if it did not need to be
rebuilt
}
\description{
Build instructor and learner HTML page
}
\details{
This function is a central workhorse that connects the global
lesson metadata and the global variables for each page to the rendering
engine: \code{{pkgdown}}. It will perform the global operations that includes
setting up the navigation (via \code{\link[=update_sidebar]{update_sidebar()}}), adding metadata, and
building both the instructor and learner versions of the page (via
\code{\link[pkgdown:render_page]{pkgdown::render_page()}}).

In the Workbench, there are three types of pages:
\enumerate{
\item primary content pages: these are primary content with a 1:1 relationship
between the source and the output. These are episodes along with custom
learner and instructor content
\item aggregate content pages: pages that are aggregated from other pages such
as key points, all-in-one, images
\item concatenated content pages: concatenations of source files and potentially
aggregate data. Examples are index, learner profiles, and the instructor
notes pages.
}

Each of these types of pages have their own process for setting up content,
which gets processed before its passed here.
}
\seealso{
\code{\link[=set_globals]{set_globals()}} for definitions of the global data,
\code{\link[=update_sidebar]{update_sidebar()}} for context of how the sidebar is updated,
}
\keyword{internal}
