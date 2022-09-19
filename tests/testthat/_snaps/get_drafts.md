# Default state reports all episodes published [plain]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      i All files in 'episodes/' published (config.yaml empty)

# Default state reports all episodes published [ansi]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      [36mi[39m All files in [34m[34mepisodes/[34m[39m published (config.yaml empty)

# Default state reports all episodes published [unicode]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      ℹ All files in 'episodes/' published (config.yaml empty)

# Default state reports all episodes published [fancy]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      [36mℹ[39m All files in [34m[34mepisodes/[34m[39m published (config.yaml empty)

# Draft episodes are reported and added episodes ignored [plain]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      i Files are in draft: 'episodes/new.Rmd'

# Draft episodes are reported and added episodes ignored [ansi]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      [36mi[39m [3m[3mFiles are in draft: [34m[3m[34mepisodes/new.Rmd[34m[3m[39m[3m[23m

# Draft episodes are reported and added episodes ignored [unicode]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      ℹ Files are in draft: 'episodes/new.Rmd'

# Draft episodes are reported and added episodes ignored [fancy]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      [36mℹ[39m [3m[3mFiles are in draft: [34m[3m[34mepisodes/new.Rmd[34m[3m[39m[3m[23m

# No draft episodes reports all episodes published [plain]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      i All files in 'episodes/' published

# No draft episodes reports all episodes published [ansi]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      [36mi[39m All files in [34m[34mepisodes/[34m[39m published

# No draft episodes reports all episodes published [unicode]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      ℹ All files in 'episodes/' published

# No draft episodes reports all episodes published [fancy]

    Code
      drf <- get_drafts(res, "episodes")
    Message
      [36mℹ[39m All files in [34m[34mepisodes/[34m[39m published

