# set_config() will set individual items [plain]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp)
    Message <cliMessage>
      - title: Lesson Title
      + title: 'test: title'
      - license: CC-BY 4.0
      + license: 'CC0'
      i To save this configuration, use
      `set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)`
    Output
      set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)

# set_config() will set individual items [ansi]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp)
    Message <cliMessage>
      [36m- [39m[2mtitle: Lesson Title[22m
      [33m+ [39mtitle: 'test: title'
      [36m- [39m[2mlicense: CC-BY 4.0[22m
      [33m+ [39mlicense: 'CC0'
      [36mi[39m To save this configuration, use
      [38;5;235m[48;5;253m[30m[47m`set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)`[48;5;253m[38;5;235m[49m[39m
    Output
      set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)

# set_config() will set individual items [unicode]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp)
    Message <cliMessage>
      - title: Lesson Title
      + title: 'test: title'
      - license: CC-BY 4.0
      + license: 'CC0'
      ℹ To save this configuration, use
      `set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)`
    Output
      set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)

# set_config() will set individual items [fancy]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp)
    Message <cliMessage>
      [36m- [39m[2mtitle: Lesson Title[22m
      [33m+ [39mtitle: 'test: title'
      [36m- [39m[2mlicense: CC-BY 4.0[22m
      [33m+ [39mlicense: 'CC0'
      [36mℹ[39m To save this configuration, use
      [38;5;235m[48;5;253m[30m[47m`set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)`[48;5;253m[38;5;235m[49m[39m
    Output
      set_config(key = c("title", "license"), value = c("test: title", 
          "CC0"), path = tmp, write = TRUE)

# set_config() will write items [plain]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp, write = TRUE)
    Message <cliMessage>
      i Writing to '[redacted]/lesson-example/config.yaml'
      > `title: Lesson Title` -> `title: 'test: title'`
      > `license: CC-BY 4.0` -> `license: 'CC0'`

# set_config() will write items [ansi]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp, write = TRUE)
    Message <cliMessage>
      [36mi[39m Writing to [34m[34m[redacted]/lesson-example/config.yaml[34m[39m
      > [38;5;235m[48;5;253m[30m[47m`title: Lesson Title`[48;5;253m[38;5;235m[49m[39m -> [38;5;235m[48;5;253m[30m[47m`title: 'test: title'`[48;5;253m[38;5;235m[49m[39m
      > [38;5;235m[48;5;253m[30m[47m`license: CC-BY 4.0`[48;5;253m[38;5;235m[49m[39m -> [38;5;235m[48;5;253m[30m[47m`license: 'CC0'`[48;5;253m[38;5;235m[49m[39m

# set_config() will write items [unicode]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp, write = TRUE)
    Message <cliMessage>
      ℹ Writing to '[redacted]/lesson-example/config.yaml'
      → `title: Lesson Title` -> `title: 'test: title'`
      → `license: CC-BY 4.0` -> `license: 'CC0'`

# set_config() will write items [fancy]

    Code
      set_config(c("title", "license"), c("test: title", "CC0"), path = tmp, write = TRUE)
    Message <cliMessage>
      [36mℹ[39m Writing to [34m[34m[redacted]/lesson-example/config.yaml[34m[39m
      → [38;5;235m[48;5;253m[30m[47m`title: Lesson Title`[48;5;253m[38;5;235m[49m[39m -> [38;5;235m[48;5;253m[30m[47m`title: 'test: title'`[48;5;253m[38;5;235m[49m[39m
      → [38;5;235m[48;5;253m[30m[47m`license: CC-BY 4.0`[48;5;253m[38;5;235m[49m[39m -> [38;5;235m[48;5;253m[30m[47m`license: 'CC0'`[48;5;253m[38;5;235m[49m[39m

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

