# set_config() will set individual items [plain]

    Code
      set_config(list(title = "test: title", license = "CC0"), path = tmp)
    Message
      - title: Lesson Title
      + title: 'test: title'
      - license: CC-BY 4.0
      + license: 'CC0'
      i To save this configuration, use
      
      `set_config(pairs = list(title = "test: title", license = "CC0"), path = tmp, write = TRUE)`

# set_config() will write items [plain]

    Code
      set_config(c(title = "test: title", license = "CC0"), path = tmp, write = TRUE)
    Message
      i Writing to '[redacted]/lesson-example/config.yaml'
      > title: Lesson Title -> title: 'test: title'
      > license: CC-BY 4.0 -> license: 'CC0'

# set_config() will write items [ansi]

    Code
      set_config(c(title = "test: title", license = "CC0"), path = tmp, write = TRUE)
    Message
      [36mi[39m Writing to [34m[34m[redacted]/lesson-example/config.yaml[34m[39m
      > title: Lesson Title -> title: 'test: title'
      > license: CC-BY 4.0 -> license: 'CC0'

# set_config() will write items [unicode]

    Code
      set_config(c(title = "test: title", license = "CC0"), path = tmp, write = TRUE)
    Message
      ℹ Writing to '[redacted]/lesson-example/config.yaml'
      → title: Lesson Title -> title: 'test: title'
      → license: CC-BY 4.0 -> license: 'CC0'

# set_config() will write items [fancy]

    Code
      set_config(c(title = "test: title", license = "CC0"), path = tmp, write = TRUE)
    Message
      [36mℹ[39m Writing to [34m[34m[redacted]/lesson-example/config.yaml[34m[39m
      → title: Lesson Title -> title: 'test: title'
      → license: CC-BY 4.0 -> license: 'CC0'

# custom keys can be modified by set_config()

    Code
      set_config(c(`test-key` = "!yeh"), path = tmp, write = TRUE)
    Message
      i Writing to '/tmp/RtmpAHEMfb/filec81490bd248/lesson-example/config.yaml'
      > test-key: 'hey!' -> test-key: '!yeh'

# set_episodes() will display the modifications if write is not specified [plain]

    Code
      s <- get_episodes(tmp)
    Message
      i No schedule set, using Rmd files in 'episodes/' directory.
      > To remove this message, define your schedule in 'config.yaml' or use `set_episodes()` to generate it.

---

    Code
      set_episodes(tmp, s[1])
    Message
      episodes:
      - 01-introduction.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - 02-new.Rmd

