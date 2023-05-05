callr_build_episode_md <- function(path, hash, workenv, outpath, workdir, root, quiet, error = TRUE) {
  # Also taken directly from tools::file_path_sans_ext
  file_path_sans_ext <- function (x) {
    sub("([^.]+)\\.[[:alnum:]]+$", "\\1", x)
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
  keng   <- knitr::knit_engines$get()
  on.exit(knitr::opts_chunk$restore(ochunk), add = TRUE)
  on.exit(knitr::opts_knit$restore(oknit), add = TRUE)
  on.exit(knitr::knit_engines$set(keng), add = TRUE)

  # START IMPORT
  # modified from knitr on 2022-08-30
  # https://github.com/yihui/knitr/blob/83fb5084daa1161d3ee2f000b637e48bdcf64617/R/engine.R
  # helper to create engines the wrap embedded html assets (e.g. css,js)
  eng_html_asset = function(prefix, postfix) {
    function(options) {
      out = if (options$eval) { # remove markdown exclusion here
        paste(c(prefix, options$code, postfix), collapse = "\n")
      }
      options$results = 'asis'
      knitr::engine_output(options, options$code, out)
    }
  }
  # include js in a script tag (ignore if not html output)
  eng_js = eng_html_asset('<script type="text/javascript">', '</script>')
  # include css in a style tag (ignore if not html output)
  eng_css = eng_html_asset('<style type="text/css">', '</style>')
  # END IMPORT

  knitr::knit_engines$set(css = eng_css, js = eng_js)

  slug <- file_path_sans_ext(basename(outpath))

  knitr::opts_chunk$set(
    error         = error,
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
