# pandoc structure is rendered correctly

    Code
      cat(readLines(out), sep = "\n")
    Output
      [RawBlock (Format "text") ""
      ,Div ("",["overview","card"],[])
       [RawBlock (Format "html") "<h2 class='card-header'>Overview</h2>"
       ,Div ("",["row","g-0"],[])
        [Div ("",["col-md-4"],[])
         [Div ("",["card-body"],[])
          [Div ("",["inner"],[])
           [RawBlock (Format "html") "<h3 class='card-title'>Questions</h3>"
           ,BulletList
            [[Plain [Str "What\8217s",Space,Str "the",Space,Str "point?"]]]]]]
        ,Div ("",["col-md-8"],[])
         [Div ("",["card-body"],[])
          [Div ("",["inner","bordered"],[])
           [RawBlock (Format "html") "<h3 class='card-title'>Objectives</h3>"
           ,BulletList
            [[Plain [Str "Bake",Space,Str "him",Space,Str "away,",Space,Str "toys"]]]]]]]]
      ,Header 1 ("markdown",[],[]) [Str "Markdown"]
      ,Div ("challenge1",["callout","challenge"],[])
       [Div ("",["callout-square"],[])
        [RawBlock (Format "html") "<i class='callout-icon' data-feather='zap'></i>"]
       ,Div ("",["callout-inner"],[])
        [Header 3 ("",["callout-title"],[]) [Str "Challenge"]
        ,Div ("",["callout-content"],[])
         [Para [Str "How",Space,Str "do",Space,Str "you",Space,Str "write",Space,Str "markdown",Space,Str "divs?"]
         ,Para [Str "This",Space,Link ("",[],[]) [Str "link",Space,Str "should",Space,Str "be",Space,Str "transformed"] ("Setup.html","")]
         ,Para [Str "This",Space,Link ("",[],[]) [Str "rmd",Space,Str "link",Space,Str "also"] ("01-Introduction.html","")]
         ,Para [Str "This",Space,Link ("",["newclass"],[]) [Str "rmd",Space,Str "is",Space,Str "safe"] ("https://example.com/01-Introduction.Rmd","")]
         ,Para [Str "This",Space,Link ("",[],[]) [Str "too"] ("Setup.html#windows-setup","windows setup")]
         ,Para [Image ("fig-first",["imgclass"],[("alt","alt text")]) [Str "link",Space,Str "should",Space,Str "be",Space,Str "transformed"] ("fig/Setup.png","fig:")]]]]
      ,Div ("accordionSolution1",["accordion","challenge-accordion","accordion-flush"],[])
       [Div ("",["accordion-item"],[])
        [RawBlock (Format "html") "<button class=\"accordion-button solution-button collapsed\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapseSolution1\" aria-expanded=\"false\" aria-controls=\"collapseSolution1\">\n  <h4 class=\"accordion-header\" id=\"headingSolution1\">\n  Write now\n  </h4>\n</button>"
        [solution collapse]
         [Div ("",["accordion-body"],[])
          [Para [Str "just",Space,Str "write",Space,Str "it,",Space,Str "silly."]]]]]
      ,Div ("accordionInstructor1",["accordion","instructor-note","accordion-flush"],[])
       [Div ("",["accordion-item"],[])
        [RawBlock (Format "html") "<button class=\"accordion-button instructor-button collapsed\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapseInstructor1\" aria-expanded=\"false\" aria-controls=\"collapseInstructor1\">\n  <h3 class=\"accordion-header\" id=\"headingInstructor1\">\n  <div class=\"note-square\"><i aria-hidden=\"true\" class=\"callout-icon\" data-feather=\"edit-2\"></i></div>\n  Instructor Note\n  </h3>\n</button>"
        [instructor collapse]
         [Div ("",["accordion-body"],[])
          [Para [Str "This",Space,Str "should",Space,Str "be",Space,Str "aside"]]]]]
      ,Div ("",["nothing"],[])
       [Para [Str "This",Space,Str "should",Space,Str "be"]]]

# paragraphs after objectives block are parsed correctly

    Code
      cat(readLines(out), sep = "\n")
    Output
      [RawBlock (Format "text") ""
      ,Div ("",["overview","card"],[])
       [RawBlock (Format "html") "<h2 class='card-header'>Overview</h2>"
       ,Div ("",["row","g-0"],[])
        [Div ("",["col-md-4"],[])
         [Div ("",["card-body"],[])
          [Div ("",["inner"],[])
           [RawBlock (Format "html") "<h3 class='card-title'>Questions</h3>"
           ,BulletList
            [[Plain [Str "What\8217s",Space,Str "the",Space,Str "point?"]]]]]]
        ,Div ("",["col-md-8"],[])
         [Div ("",["card-body"],[])
          [Div ("",["inner","bordered"],[])
           [RawBlock (Format "html") "<h3 class='card-title'>Objectives</h3>"
           ,BulletList
            [[Plain [Str "Bake",Space,Str "him",Space,Str "away,",Space,Str "toys"]]]]]]]]
      ,Para [Str "Do",Space,Str "you",Space,Str "think",Space,Str "he",Space,Str "saurus?"]
      ,Header 1 ("markdown",[],[]) [Str "Markdown"]]

# render_html applies the internal lua filter

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
      <div class="float" id="fig-first">
      <img src="fig/Setup.png" class="imgclass" alt="alt text" />
      <div class="figcaption">link should be transformed</div>
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

