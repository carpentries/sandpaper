# set_episode() will throw an error if an episode does not exist [plain]

    Code
      expect_error(set_episodes(res, bad, write = TRUE))
    Message <cliMessage>
      episodes:
      - '01-introduction.Rmd'
      - x I-do-not-exist.md

# set_episode() will throw an error if an episode does not exist [ansi]

    Code
      expect_error(set_episodes(res, bad, write = TRUE))
    Message <cliMessage>
      episodes:
      - [34m[34m01-introduction.Rmd[34m[39m
      - x [1m[1mI-do-not-exist.md[1m[22m

# set_episode() will throw an error if an episode does not exist [unicode]

    Code
      expect_error(set_episodes(res, bad, write = TRUE))
    Message <cliMessage>
      episodes:
      - '01-introduction.Rmd'
      - ✖ I-do-not-exist.md

# set_episode() will throw an error if an episode does not exist [fancy]

    Code
      expect_error(set_episodes(res, bad, write = TRUE))
    Message <cliMessage>
      episodes:
      - [34m[34m01-introduction.Rmd[34m[39m
      - ✖ [1m[1mI-do-not-exist.md[1m[22m

# get_episode() will throw a message about episode in draft [plain]

    Code
      drafty_out <- get_episodes(res)
    Message <cliMessage>
      i Files are in draft: 'episodes/02-new.Rmd'

# get_episode() will throw a message about episode in draft [ansi]

    Code
      drafty_out <- get_episodes(res)
    Message <cliMessage>
      [36mi[39m [3m[3mFiles are in draft: [34m[3m[34mepisodes/02-new.Rmd[34m[3m[39m[3m[23m

# get_episode() will throw a message about episode in draft [unicode]

    Code
      drafty_out <- get_episodes(res)
    Message <cliMessage>
      ℹ Files are in draft: 'episodes/02-new.Rmd'

# get_episode() will throw a message about episode in draft [fancy]

    Code
      drafty_out <- get_episodes(res)
    Message <cliMessage>
      [36mℹ[39m [3m[3mFiles are in draft: [34m[3m[34mepisodes/02-new.Rmd[34m[3m[39m[3m[23m

# get_episode() will throw a warning if an episode in config does not exist [plain]

    Code
      expect_error(get_episodes(res))
    Message <cliMessage>
      episodes:
      - '01-introduction.Rmd'
      - x I-am-an-impostor.md

# get_episode() will throw a warning if an episode in config does not exist [ansi]

    Code
      expect_error(get_episodes(res))
    Message <cliMessage>
      episodes:
      - [34m[34m01-introduction.Rmd[34m[39m
      - x [1m[1mI-am-an-impostor.md[1m[22m

# get_episode() will throw a warning if an episode in config does not exist [unicode]

    Code
      expect_error(get_episodes(res))
    Message <cliMessage>
      episodes:
      - '01-introduction.Rmd'
      - ✖ I-am-an-impostor.md

# get_episode() will throw a warning if an episode in config does not exist [fancy]

    Code
      expect_error(get_episodes(res))
    Message <cliMessage>
      episodes:
      - [34m[34m01-introduction.Rmd[34m[39m
      - ✖ [1m[1mI-am-an-impostor.md[1m[22m

