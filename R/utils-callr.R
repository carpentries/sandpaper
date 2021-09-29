callr_build_episode_md <- function(path, hash, workenv, outpath, workdir, root, quiet) {
  # Shortcut if the source is a markdown file
  # Taken directly from tools::file_ext
  file_ext <- function (x) {
    pos <- regexpr("\\.([[:alnum:]]+)$", x)
    ifelse(pos > -1L, substring(x, pos + 1L), "")
  }
  # Also taken directly from tools::file_path_sans_ext
  file_path_sans_ext <- function (x) {
    sub("([^.]+)\\.[[:alnum:]]+$", "\\1", x)
  }
  if (file_ext(path) == "md") {
    file.copy(path, outpath, overwrite = TRUE)
    return(NULL)
  }
  # Load required packages if it's an RMarkdown file and we know the root 
  # directory.
  if (root != "") {
    renv::load(root)
    on.exit(invisible(utils::capture.output(renv::deactivate(root), type = "message")), add = TRUE)
  }
  # Set knitr options for output ---------------------------
  ochunk <- knitr::opts_chunk$get()
  oknit  <- knitr::opts_knit$get()
  on.exit(knitr::opts_chunk$restore(ochunk), add = TRUE)
  on.exit(knitr::opts_knit$restore(oknit), add = TRUE)

  slug <- file_path_sans_ext(basename(outpath))

  knitr::opts_chunk$set(
    comment       = "",
    fig.align     = "center",
    class.output  = "output",
    class.error   = "error",
    class.warning = "warning",
    class.message = "output",
    fig.path      = file.path("fig", paste0(slug, "-rendered-"))
  )

  knitr::opts_knit$set(
    # set our working directory to not pollute source
    root.dir = workdir,
    # Ensure HTML options like caption are respected by code chunks
    rmarkdown.pandoc.to = "markdown"
  )

  # Set the working directory -----------------------------
  wd <- getwd()
  on.exit(setwd(wd), add = TRUE)
  setwd(workdir)

  # Generate markdown -------------------------------------
  knitr::knit(
    input    = path,
    output   = outpath,
    envir    = workenv,
    quiet    = quiet,
    encoding = "UTF-8"
  )
}
