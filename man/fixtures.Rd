% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test-fixtures.R
\name{create_test_lesson}
\alias{create_test_lesson}
\alias{generate_restore_fixture}
\alias{setup_local_remote}
\alias{make_branch}
\alias{clean_branch}
\alias{remove_local_remote}
\title{Test fixture functions for sandpaper}
\usage{
create_test_lesson()

generate_restore_fixture(repo)

setup_local_remote(
  repo,
  remote = tempfile(),
  name = "sandpaper-local",
  verbose = FALSE
)

make_branch(repo, branch = NULL, name = "sandpaper-local", verbose = FALSE)

clean_branch(repo, branch = NULL, name = "sandpaper-local", verbose = FALSE)

remove_local_remote(repo, name = "sandpaper-local")
}
\arguments{
\item{repo}{path to a git repository}

\item{remote}{path to an empty or uninitialized directory. Defaults to a
tempfile}

\item{name}{of the remote, defaults to "sandpaper-local"}

\item{verbose}{if \code{TRUE}, messages and output from git will be printed to
screen. Defaults to \code{FALSE}.}

\item{branch}{the name of the new branch to be deleted}
}
\value{
(\code{generate_restore_fixture}) a function that will restore the test fixture

(\code{setup_local_remote()}) the repo, invisibly

(\code{remove_local_remote()}) FALSE indicating an error or a string
indicating the path to the remote
}
\description{
This suite of functions are for use during testing of \code{{sandpaper}} and are
designed to create/work with a temporary lesson and associated remote
repository (locally) that persists throughout the test suite. These functions
are used in \code{tests/testthat/setup.R}. For more information, see the \href{https://testthat.r-lib.org/articles/test-fixtures.html#package}{package scope section of testthat article on Test Fixtures}.
}
\details{
\subsection{\code{create_test_lesson()}}{

This creates the test lesson and calls \code{generate_restore_fixture()} with the
path of the new test lesson.
}

\subsection{\code{generate_restore_fixture()}}{

This creates a function that will restore a lesson to its previous commit.
}

\subsection{\code{setup_local_remote()}}{

Creates a local remote repository in a separate temporary folder, linked to
the fixture lesson.
}

\subsection{\code{make_branch()}}{

create a branch in the local repository and push it to the remote repository.
}

\subsection{\code{clean_branch()}}{

delete a branch in the local and remote repository.
}

\subsection{\code{remove_local_remote()}}{

Destorys the local remote repository and removes it from the fixture lesson
}
}
\note{
These are implemented in tests/testthat/setup.md
}
\keyword{internal}
