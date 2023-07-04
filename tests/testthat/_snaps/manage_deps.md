# package cache message appears correct [plain]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message
      
      -- Caching Build Packages for Generated Content --------------------------------
      The Carpentries lesson infrastructure uses the renv (R environment) package to
      maintain reproducibility for lessons with generated content. It looks like you
      have not yet used renv before, so this is a one-time message that gives you
      information about how the package cache can help you with your lesson.
      
      Finally, renv maintains a local cache of data on the filesystem, located at:
      
      - "/path/to/cache"
      
      This path can be customized: please see the documentation in `?renv::paths`.
      
      > This may take some time to set up the first time you use it, but once the
      cache is established, the process will run much more quickly.
      
      If you choose not to use the package cache, be aware that you may find
      differences between the lesson you render on your computer and what is rendered
      online.
      
      Do you want to using a package cache for Carpentries lessons?
      -- Enter your selection or press 0 to exit -------------------------------------
    Output
      1: Yes, please use the package cache (recommended)
      2: No, I want to use my default library

# package cache message appears correct [ansi]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message
      
      [36m--[39m [1mCaching Build Packages for Generated Content[22m [36m--------------------------------[39m
      The Carpentries lesson infrastructure uses the [34mrenv[39m (R environment) package to
      maintain reproducibility for lessons with generated content. It looks like you
      have not yet used [34mrenv[39m before, so [1mthis is a one-time message[22m that gives you
      information about how the package cache can help you with your lesson.
      
      [30m[47mFinally, renv maintains a local cache of data on the filesystem, located at:[49m[39m
      
      - "/path/to/cache"
      
      This path can be customized: please see the documentation in `?renv::paths`.
      
      > This may take some time to set up the first time you use it, but once the
      cache is established, the process will run much more quickly.
      
      If you choose not to use the package cache, be aware that you may find
      differences between the lesson you render on your computer and what is rendered
      online.
      
      [1mDo you want to using a package cache for Carpentries lessons?[22m
      -- Enter your selection or press 0 to exit -------------------------------------
    Output
      1: [1mYes[22m, please use the package cache (recommended)
      2: [1mNo[22m, I want to use my default library

# pacakge cache message appears correct [unicode]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message
      
      ── Caching Build Packages for Generated Content ────────────────────────────────
      The Carpentries lesson infrastructure uses the renv (R environment) package to
      maintain reproducibility for lessons with generated content. It looks like you
      have not yet used renv before, so this is a one-time message that gives you
      information about how the package cache can help you with your lesson.
      
      Finally, renv maintains a local cache of data on the filesystem, located at:
      
      - "/path/to/cache"
      
      This path can be customized: please see the documentation in `?renv::paths`.
      
      → This may take some time to set up the first time you use it, but once the
      cache is established, the process will run much more quickly.
      
      If you choose not to use the package cache, be aware that you may find
      differences between the lesson you render on your computer and what is rendered
      online.
      
      Do you want to using a package cache for Carpentries lessons?
      ── Enter your selection or press 0 to exit ─────────────────────────────────────
    Output
      1: Yes, please use the package cache (recommended)
      2: No, I want to use my default library

# pacakge cache message appears correct [fancy]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message
      
      [36m──[39m [1mCaching Build Packages for Generated Content[22m [36m────────────────────────────────[39m
      The Carpentries lesson infrastructure uses the [34mrenv[39m (R environment) package to
      maintain reproducibility for lessons with generated content. It looks like you
      have not yet used [34mrenv[39m before, so [1mthis is a one-time message[22m that gives you
      information about how the package cache can help you with your lesson.
      
      [30m[47mFinally, renv maintains a local cache of data on the filesystem, located at:[49m[39m
      
      - "/path/to/cache"
      
      This path can be customized: please see the documentation in `?renv::paths`.
      
      → This may take some time to set up the first time you use it, but once the
      cache is established, the process will run much more quickly.
      
      If you choose not to use the package cache, be aware that you may find
      differences between the lesson you render on your computer and what is rendered
      online.
      
      [1mDo you want to using a package cache for Carpentries lessons?[22m
      ── Enter your selection or press 0 to exit ─────────────────────────────────────
    Output
      1: [1mYes[22m, please use the package cache (recommended)
      2: [1mNo[22m, I want to use my default library

