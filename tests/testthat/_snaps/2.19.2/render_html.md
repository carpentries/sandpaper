# render_html applies the internal lua filter [2.19.2]

    Code
      cat(res)
    Output
      <div class="overview card">
      <h2 class='card-header'>Overview</h2>
      <div class="row g-0">
      <div class="col-md-4">
      <div class="card-body">
      <div class="inner">
      <h3 class='card-title'>Questions</h3>
      <ul>
      <li>What’s the point?</li>
      </ul>
      </div>
      </div>
      </div>
      <div class="col-md-8">
      <div class="card-body">
      <div class="inner bordered">
      <h3 class='card-title'>Objectives</h3>
      <ul>
      <li>Bake him away, toys</li>
      </ul>
      </div>
      </div>
      </div>
      </div>
      </div>
      <div id="markdown" class="section level1">
      <h1>Markdown</h1>
      <div id="challenge1" class="callout challenge">
      <div class="callout-square">
      <i class='callout-icon' data-feather='zap'></i>
      </div>
      <div class="section level3 callout-title callout-inner">
      <h3 class="callout-title">Challenge</h3>
      <div class="callout-content">
      <p>How do you write markdown divs?</p>
      <p>This <a href="Setup.html">link should be transformed</a></p>
      <p>This <a href="01-Introduction.html">rmd link also</a></p>
      <p>This <a href="https://example.com/01-Introduction.Rmd"
      class="newclass">rmd is safe</a></p>
      <p>This <a href="Setup.html#windows-setup"
      title="windows setup">too</a></p>
      <div class="figure">
      <img src="fig/Setup.png" id="fig-first" class="imgclass"
      alt="alt text" />
      <p class="caption">link should be transformed</p>
      </div>
      </div>
      </div>
      </div>
      <div id="accordionSolution1"
      class="accordion challenge-accordion accordion-flush">
      <div class="accordion-item">
      <button class="accordion-button solution-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseSolution1" aria-expanded="false" aria-controls="collapseSolution1">
        <h4 class="accordion-header" id="headingSolution1">
        Write now
        </h4>
      </button>
      [solution collapse]
      [data/aria-collapse]
      <div class="accordion-body">
      <p>just write it, silly.</p>
      </div>
      </div>
      </div>
      </div>
      <div id="accordionInstructor1"
      class="accordion instructor-note accordion-flush">
      <div class="accordion-item">
      <button class="accordion-button instructor-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseInstructor1" aria-expanded="false" aria-controls="collapseInstructor1">
        <h3 class="accordion-header" id="headingInstructor1">
        <div class="note-square"><i aria-hidden="true" class="callout-icon" data-feather="edit-2"></i></div>
        Instructor Note
        </h3>
      </button>
      [instructor collapse]
      [data/aria-collapse]
      [data/aria-collapse]
      <div class="accordion-body">
      <p>This should be aside</p>
      </div>
      </div>
      </div>
      </div>
      <div class="nothing">
      <p>This should be</p>
      </div>
      </div>

