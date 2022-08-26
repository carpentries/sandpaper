# Episodes can be moved to a different position [plain]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

# Episodes can be moved to a different position [ansi]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

# Episodes can be moved to a different position [unicode]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

# Episodes can be moved to a different position [fancy]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

# Episodes can be moved out of position [plain]

    Code
      move_episode("new-mewtwo-three.Rmd", 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - new-mewtwo-three.Rmd

---

    Code
      move_episode(3, 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - new-mewtwo-three.Rmd

# Episodes can be moved out of position [ansi]

    Code
      move_episode("new-mewtwo-three.Rmd", 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - [3mnew-mewtwo-three.Rmd[23m

---

    Code
      move_episode(3, 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - [3mnew-mewtwo-three.Rmd[23m

# Episodes can be moved out of position [unicode]

    Code
      move_episode("new-mewtwo-three.Rmd", 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      ── Removed episodes ────────────────────────────────────────────────────────────
      - new-mewtwo-three.Rmd

---

    Code
      move_episode(3, 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      ── Removed episodes ────────────────────────────────────────────────────────────
      - new-mewtwo-three.Rmd

# Episodes can be moved out of position [fancy]

    Code
      move_episode("new-mewtwo-three.Rmd", 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      ── Removed episodes ────────────────────────────────────────────────────────────
      - [3mnew-mewtwo-three.Rmd[23m

---

    Code
      move_episode(3, 0, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      ── Removed episodes ────────────────────────────────────────────────────────────
      - [3mnew-mewtwo-three.Rmd[23m

# Drafts can be added to the index [plain]

    Code
      move_episode("new-mewtwo-three.Rmd", 1, write = FALSE, path = res)
    Message
      episodes:
      - new-mewtwo-three.Rmd
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = TRUE, path = res)

# Drafts can be added to the index [ansi]

    Code
      move_episode("new-mewtwo-three.Rmd", 1, write = FALSE, path = res)
    Message
      episodes:
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = TRUE, path = res)

# Drafts can be added to the index [unicode]

    Code
      move_episode("new-mewtwo-three.Rmd", 1, write = FALSE, path = res)
    Message
      episodes:
      - new-mewtwo-three.Rmd
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = TRUE, path = res)

# Drafts can be added to the index [fancy]

    Code
      move_episode("new-mewtwo-three.Rmd", 1, write = FALSE, path = res)
    Message
      episodes:
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = TRUE, path = res)

