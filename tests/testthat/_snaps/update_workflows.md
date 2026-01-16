# github workflows can be fetched [plain]

    Code
      update_github_workflows(tmp)
    Message
      i Workflows/files updated:
      - '.github/workflows/deleteme.yaml' (deleted)

# github workflows can be fetched [ansi]

    Code
      update_github_workflows(tmp)
    Message
      [36mi[39m Workflows/files updated:
      - [34m.github/workflows/deleteme.yaml[39m [3m(deleted)[23m

# github workflows can be fetched [unicode]

    Code
      update_github_workflows(tmp)
    Message
      ℹ Workflows/files updated:
      - '.github/workflows/deleteme.yaml' (deleted)

# github workflows can be fetched [fancy]

    Code
      update_github_workflows(tmp)
    Message
      [36mℹ[39m Workflows/files updated:
      - [34m.github/workflows/deleteme.yaml[39m [3m(deleted)[23m

# github workflows are recognized as up-to-date

    Code
      update_github_workflows(tmp)
    Message
      i Workflows/files updated:
      - '.github/workflows/sandpaper-version.txt' (modified)

# nothing happens when the versions are aligned

    Code
      update_github_workflows(tmp, overwrite = FALSE)
    Message
      i Workflows up-to-date!

---

    Code
      update_github_workflows(tmp)
    Message
      i Workflows up-to-date!

