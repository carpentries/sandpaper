# [build_home()] learner index file is index and setup

    Code
      writeLines(as.character(items))
    Output
      <li><a href="#data-sets">Data Sets</a></li>
      <li><a href="#software-setup">Software Setup</a></li>
      <li>
                              <a href="key-points.html">Key Points</a>
                            </li>
      <li>
                              <a href="reference.html#glossary">Glossary</a>
                            </li>
      <li>
                              <a href="profiles.html">Learner Profiles</a>
                            </li>

# [build_home()] instructor index file is index and schedule

    Code
      writeLines(as.character(items))
    Output
      <li>
                              <a href="../instructor/key-points.html">Key Points</a>
                            </li>
      <li>
                              <a href="../instructor/instructor-notes.html">Instructor Notes</a>
                            </li>
      <li>
                              <a href="../instructor/images.html">Extract All Images</a>
                            </li>

# [build_profiles()] learner and instructor views are identical

    Code
      writeLines(sidelinks_instructor)
    Output
      <a href="../profiles.html">Learner View</a>
      <a href="index.html">Summary and Schedule</a>
      <a href="introduction.html">1. introduction</a>
      <a href="../instructor/key-points.html">Key Points</a>
      <a href="../instructor/instructor-notes.html">Instructor Notes</a>
      <a href="../instructor/images.html">Extract All Images</a>
      <a href="../instructor/aio.html">See all in one page</a>

---

    Code
      writeLines(sidelinks_learner)
    Output
      <a href="instructor/profiles.html">Instructor View</a>
      <a href="index.html">Summary and Setup</a>
      <a href="introduction.html">1. introduction</a>
      <a href="key-points.html">Key Points</a>
      <a href="reference.html#glossary">Glossary</a>
      <a href="profiles.html">Learner Profiles</a>
      <a href="aio.html">See all in one page</a>

