# pacakge cache message appears correct [plain]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message <cliMessage>
      
      -- Caching Build Packages for Generated Content --------------------------------
      The Carpentries lesson infrastructure uses the renv (R environment) package to
      maintain reproducibility for lessons with generated content. It looks like you
      have not yet used renv before, so this is a one-time message that gives you
      information about how the package cache can help you with your lesson.
      
      renv maintains a local cache of data on the filesystem, located at:
      
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

# pacakge cache message appears correct [ansi]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message <cliMessage>
      
      [36m--[39m [1m[1mCaching Build Packages for Generated Content[1m[22m [36m--------------------------------[39m
      The Carpentries lesson infrastructure uses the [34m[34mrenv[34m[39m (R environment) package to[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39mmaintain reproducibility for lessons with generated content. It looks like you[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39mhave not yet used [34m[34mrenv[34m[39m before, so [1m[1mthis is a one-time message[1m[22m that gives you[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22minformation about how the package cache can help you with your lesson.[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47mrenv maintains a local cache of data on the filesystem, located at:[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m- "/path/to/cache"[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47mThis path can be customized: please see the documentation in `?renv::paths`.[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m> This may take some time to set up the first time you use it, but once the[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39mcache is established, the process will run much more quickly.[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39mIf you choose not to use the package cache, be aware that you may find[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39mdifferences between the lesson you render on your computer and what is rendered[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39monline.[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1mDo you want to using a package cache for Carpentries lessons?[1m[22m
      -- Enter your selection or press 0 to exit -------------------------------------
    Output
      1: [1mYes[22m, please use the package cache (recommended)
      2: [1mNo[22m, I want to use my default library

# pacakge cache message appears correct [unicode]

    Code
      cat(paste(c("1:", "2:"), sandpaper:::message_package_cache(msg)), sep = "\n")
    Message <cliMessage>
      
      ── Caching Build Packages for Generated Content ────────────────────────────────
      The Carpentries lesson infrastructure uses the renv (R environment) package to
      maintain reproducibility for lessons with generated content. It looks like you
      have not yet used renv before, so this is a one-time message that gives you
      information about how the package cache can help you with your lesson.
      
      renv maintains a local cache of data on the filesystem, located at:
      
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
    Message <cliMessage>
      
      [36m──[39m [1m[1mCaching Build Packages for Generated Content[1m[22m [36m────────────────────────────────[39m
      The Carpentries lesson infrastructure uses the [34m[34mrenv[34m[39m (R environment) package to[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39mmaintain reproducibility for lessons with generated content. It looks like you[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39mhave not yet used [34m[34mrenv[34m[39m before, so [1m[1mthis is a one-time message[1m[22m that gives you[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22minformation about how the package cache can help you with your lesson.[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47mrenv maintains a local cache of data on the filesystem, located at:[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m- "/path/to/cache"[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47mThis path can be customized: please see the documentation in `?renv::paths`.[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m→ This may take some time to set up the first time you use it, but once the[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39mcache is established, the process will run much more quickly.[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39mIf you choose not to use the package cache, be aware that you may find[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39mdifferences between the lesson you render on your computer and what is rendered[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39monline.[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1m[1m[1m[1m[22m
      [34m[34m[34m[39m[34m[34m[34m[39m[1m[1m[1m[22m[30m[47m[30m[47m[47m[30m[49m[39m[1m[1mDo you want to using a package cache for Carpentries lessons?[1m[22m
      ── Enter your selection or press 0 to exit ─────────────────────────────────────
    Output
      1: [1mYes[22m, please use the package cache (recommended)
      2: [1mNo[22m, I want to use my default library

