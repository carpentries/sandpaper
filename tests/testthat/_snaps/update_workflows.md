# github workflows can be fetched [plain]

    Code
      update_github_workflows(tmp)
    Message <cliMessage>
      i Workflows/files updated:
      - '.github/workflows/deleteme.yaml' (deleted)
      - '.github/workflows/sandpaper-main.yaml' (new)

# github workflows can be fetched [ansi]

    Code
      update_github_workflows(tmp)
    Message <cliMessage>
      [36mi[39m Workflows/files updated:
      - [34m[34m.github/workflows/deleteme.yaml[34m[39m [3m[3m(deleted)[3m[23m
      - [34m[34m.github/workflows/sandpaper-main.yaml[34m[39m [3m[3m(new)[3m[23m

# github workflows can be fetched [unicode]

    Code
      update_github_workflows(tmp)
    Message <cliMessage>
      ℹ Workflows/files updated:
      - '.github/workflows/deleteme.yaml' (deleted)
      - '.github/workflows/sandpaper-main.yaml' (new)

# github workflows can be fetched [fancy]

    Code
      update_github_workflows(tmp)
    Message <cliMessage>
      [36mℹ[39m Workflows/files updated:
      - [34m[34m.github/workflows/deleteme.yaml[34m[39m [3m[3m(deleted)[3m[23m
      - [34m[34m.github/workflows/sandpaper-main.yaml[34m[39m [3m[3m(new)[3m[23m

# github workflows can be updated [plain]

    Code
      update_github_workflows(tmp, "sandpaper-main.yaml")
    Message <cliMessage>
      i Workflows/files updated:
      - '.github/workflows/sandpaper-main.yaml' (modified)

# github workflows can be updated [ansi]

    Code
      update_github_workflows(tmp, "sandpaper-main.yaml")
    Message <cliMessage>
      [36mi[39m Workflows/files updated:
      - [34m[34m.github/workflows/sandpaper-main.yaml[34m[39m [3m[3m(modified)[3m[23m

# github workflows can be updated [unicode]

    Code
      update_github_workflows(tmp, "sandpaper-main.yaml")
    Message <cliMessage>
      ℹ Workflows/files updated:
      - '.github/workflows/sandpaper-main.yaml' (modified)

# github workflows can be updated [fancy]

    Code
      update_github_workflows(tmp, "sandpaper-main.yaml")
    Message <cliMessage>
      [36mℹ[39m Workflows/files updated:
      - [34m[34m.github/workflows/sandpaper-main.yaml[34m[39m [3m[3m(modified)[3m[23m

# github workflows are recognized as up-to-date

    Code
      update_github_workflows(tmp)
    Message <cliMessage>
      i Workflows/files updated:
      - '.github/workflows/sandpaper-version.txt' (modified)

# nothing happens when the versions are aligned

    Code
      update_github_workflows(tmp, overwrite = FALSE)
    Message <cliMessage>
      i Workflows up-to-date!

---

    Code
      update_github_workflows(tmp)
    Message <cliMessage>
      i Workflows up-to-date!

