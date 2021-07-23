# set_episodes() will display the modifications if write is not specified [plain]

    Code
      s <- get_episodes(tmp)
    Message <cliMessage>
      i No schedule set, using Rmd files in 'episodes/' directory.
      > To remove this message, define your schedule in 'config.yaml' or use `set_episodes()` to generate it.

---

    Code
      set_episodes(tmp, s[1])
    Output
      episodes:
      - 01-introduction.Rmd
    Message <cliMessage>
      -- Removed episodes ------------------------------------------------------------
    Output
      x 02-new.Rmd

# set_episodes() will display the modifications if write is not specified [ansi]

    Code
      s <- get_episodes(tmp)
    Message <cliMessage>
      [36mi[39m No schedule set, using Rmd files in [34m[34mepisodes/[34m[39m directory.
      [3m[3m> [2mTo remove this message, define your schedule in [34m[3m[34mconfig.yaml[34m[3m[39m or use [38;5;235m[48;5;253m[3m[30m[47m`set_episodes()`[48;5;253m[38;5;235m[3m[49m[39m to generate it.[22m[3m[23m

---

    Code
      set_episodes(tmp, s[1])
    Output
      episodes:
      - 01-introduction.Rmd
    Message <cliMessage>
      -- Removed episodes ------------------------------------------------------------
    Output
      [31mx[39m 02-new.Rmd

# set_episodes() will display the modifications if write is not specified [unicode]

    Code
      s <- get_episodes(tmp)
    Message <cliMessage>
      ℹ No schedule set, using Rmd files in 'episodes/' directory.
      → To remove this message, define your schedule in 'config.yaml' or use `set_episodes()` to generate it.

---

    Code
      set_episodes(tmp, s[1])
    Output
      episodes:
      ─ 01-introduction.Rmd
    Message <cliMessage>
      ── Removed episodes ────────────────────────────────────────────────────────────
    Output
      ✖ 02-new.Rmd

# set_episodes() will display the modifications if write is not specified [fancy]

    Code
      s <- get_episodes(tmp)
    Message <cliMessage>
      [36mℹ[39m No schedule set, using Rmd files in [34m[34mepisodes/[34m[39m directory.
      [3m[3m→ [2mTo remove this message, define your schedule in [34m[3m[34mconfig.yaml[34m[3m[39m or use [38;5;235m[48;5;253m[3m[30m[47m`set_episodes()`[48;5;253m[38;5;235m[3m[49m[39m to generate it.[22m[3m[23m

---

    Code
      set_episodes(tmp, s[1])
    Output
      episodes:
      ─ 01-introduction.Rmd
    Message <cliMessage>
      ── Removed episodes ────────────────────────────────────────────────────────────
    Output
      [31m✖[39m 02-new.Rmd

