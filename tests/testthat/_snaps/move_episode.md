# no position will trigger an interactive search [plain]

    Code
      tryCatch(move_episode(1, path = res), error = function(e) e$message)
    Message
      i Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-mewtwo-three.Rmd
      4. new-too.Rmd
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

---

    Code
      tryCatch(move_episode("new-mewtwo-three.Rmd", path = res), error = function(e)
        e$message)
    Message
      i Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-too.Rmd
      4. [insert at end]
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

# no position will trigger an interactive search [ansi]

    Code
      tryCatch(move_episode(1, path = res), error = function(e) e$message)
    Message
      [36mi[39m Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-mewtwo-three.Rmd
      4. new-too.Rmd
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

---

    Code
      tryCatch(move_episode("new-mewtwo-three.Rmd", path = res), error = function(e)
        e$message)
    Message
      [36mi[39m Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-too.Rmd
      4. [insert at end]
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

# no position will trigger an interactive search [unicode]

    Code
      tryCatch(move_episode(1, path = res), error = function(e) e$message)
    Message
      ℹ Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-mewtwo-three.Rmd
      4. new-too.Rmd
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

---

    Code
      tryCatch(move_episode("new-mewtwo-three.Rmd", path = res), error = function(e)
        e$message)
    Message
      ℹ Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-too.Rmd
      4. [insert at end]
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

# no position will trigger an interactive search [fancy]

    Code
      tryCatch(move_episode(1, path = res), error = function(e) e$message)
    Message
      [36mℹ[39m Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-mewtwo-three.Rmd
      4. new-too.Rmd
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

---

    Code
      tryCatch(move_episode("new-mewtwo-three.Rmd", path = res), error = function(e)
        e$message)
    Message
      [36mℹ[39m Select a number to insert your episode
      (if an episode already occupies that position, it will be shifted down)
      
      1. introduction.Rmd
      2. new.Rmd
      3. new-too.Rmd
      4. [insert at end]
      
    Output
      [1] "Can not move an episode to position -1, it is out of bounds."

# Episodes can be moved to a different position [plain]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "new-too.Rmd", position = 3, write = TRUE, path = res)`

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "introduction.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = 4, position = 3, write = TRUE, path = res)`

# Episodes can be moved to a different position [ansi]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "new-too.Rmd", position = 3, write = TRUE, path = res)`

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "introduction.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = 4, position = 3, write = TRUE, path = res)`

# Episodes can be moved to a different position [unicode]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "new-too.Rmd", position = 3, write = TRUE, path = res)`

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "introduction.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = 4, position = 3, write = TRUE, path = res)`

# Episodes can be moved to a different position [fancy]

    Code
      move_episode("new-too.Rmd", 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "new-too.Rmd", position = 3, write = TRUE, path = res)`

---

    Code
      move_episode("introduction.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - new.Rmd
      - new-mewtwo-three.Rmd
      - new-too.Rmd
      - introduction.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "introduction.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode(4, 3, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = 4, position = 3, write = TRUE, path = res)`

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
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 0, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", FALSE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - new-mewtwo-three.Rmd
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = FALSE, write = TRUE, path = res)`

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
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = 3, position = 0, write = TRUE, path = res)`

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
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 0, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", FALSE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      -- Removed episodes ------------------------------------------------------------
      - [3mnew-mewtwo-three.Rmd[23m
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = FALSE, write = TRUE, path = res)`

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
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = 3, position = 0, write = TRUE, path = res)`

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
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 0, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", FALSE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      ── Removed episodes ────────────────────────────────────────────────────────────
      - new-mewtwo-three.Rmd
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = FALSE, write = TRUE, path = res)`

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
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = 3, position = 0, write = TRUE, path = res)`

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
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 0, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", FALSE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      ── Removed episodes ────────────────────────────────────────────────────────────
      - [3mnew-mewtwo-three.Rmd[23m
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = FALSE, write = TRUE, path = res)`

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
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = 3, position = 0, write = TRUE, path = res)`

# Drafts can be added to the index [plain]

    Code
      move_episode("new-mewtwo-three.Rmd", 1, write = FALSE, path = res)
    Message
      episodes:
      - new-mewtwo-three.Rmd
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 1, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", TRUE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4L, write = TRUE, path = res)`

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
      
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 1, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", TRUE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      
      --------------------------------------------------------------------------------
      [36mi[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4L, write = TRUE, path = res)`

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
      
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 1, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", TRUE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - new-mewtwo-three.Rmd
      
      ────────────────────────────────────────────────────────────────────────────────
      ℹ To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4L, write = TRUE, path = res)`

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
      
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 1, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", TRUE, write = FALSE, path = res)
    Message
      episodes:
      - introduction.Rmd
      - new.Rmd
      - new-too.Rmd
      - [1m[36mnew-mewtwo-three.Rmd[39m[22m
      
      ────────────────────────────────────────────────────────────────────────────────
      [36mℹ[39m To save this configuration, use
      
      `move_episode(ep = "new-mewtwo-three.Rmd", position = 4L, write = TRUE, path = res)`

---

    Code
      move_episode("new-mewtwo-three.Rmd", 4, write = TRUE, path = res)

