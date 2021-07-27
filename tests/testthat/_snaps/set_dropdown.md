# set_episodes() will display the modifications if write is not specified [plain]

    Code
      s <- get_episodes(tmp)
    Message <cliMessage>
      i No schedule set, using Rmd files in 'episodes/' directory.
      > To remove this message, define your schedule in 'config.yaml' or use `set_episodes()` to generate it.

---

    Code
      set_episodes(tmp, s[1])
    Message <cliMessage>
      episodes:
      - 01-introduction.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - 02-new.Rmd

