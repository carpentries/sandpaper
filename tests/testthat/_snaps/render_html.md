# pandoc structure is rendered correctly

    Code
      cat(readLines(out), sep = "\n")
    Output
      [Null
      ,Div ("",["objectives"],[])
       [Header 2 ("",[],[]) [Str "Overview"]
       ,Div ("",["row"],[])
        [Div ("",["col-md-3"],[])
         [Para [Strong [Str "Teaching: "],Space,Str "6",LineBreak,Strong [Str "Exercises: "],Space,Str "9"]]
        ,Div ("",["col-md-9"],[])
         [Para [Strong [Str "Questions"]]
         ,BulletList
          [[Plain [Str "What\8217s",Space,Str "the",Space,Str "point?"]]]]]
       ,Div ("",["row"],[])
        [Div ("",["col-md-3"],[])
         []
        ,Div ("",["col-md-9"],[])
         [Para [Strong [Str "Objectives"]]
         ,BulletList
          [[Plain [Str "Bake",Space,Str "him",Space,Str "away,",Space,Str "toys"]]]]]]
      ,Header 1 ("markdown",[],[]) [Str "Markdown"]
      ,Div ("",["challenge"],[])
       [Header 2 ("",[],[]) [Str "Challenge"]
       ,Para [Str "How",Space,Str "do",Space,Str "you",Space,Str "write",Space,Str "markdown",Space,Str "divs?"]
       ,Para [Str "This",Space,Link ("",[],[]) [Str "link",Space,Str "should",Space,Str "be",Space,Str "transformed"] ("Setup.html","")]
       ,Para [Str "This",Space,Link ("",[],[]) [Str "too"] ("Setup.html#windows-setup","windows setup")]
       ,Para [Image ("",[],[("alt","alt text")]) [Str "link",Space,Str "should",Space,Str "be",Space,Str "transformed"] ("fig/Setup.png","fig:")]
       ,Div ("",["solution"],[])
        [Header 2 ("write-now",[],[]) [Str "Write",Space,Str "now"]
        ,Para [Str "just",Space,Str "write",Space,Str "it,",Space,Str "silly."]]]
      ,RawBlock (Format "html") "<aside class=\"instructor\">"
      ,Div ("",[],[])
       [Para [Str "This",Space,Str "should",Space,Str "be",Space,Str "aside"]]
      ,RawBlock (Format "html") "</aside>"
      ,Div ("",["nothing"],[])
       [Para [Str "This",Space,Str "should",Space,Str "be"]]]

# paragraphs after objectives block are parsed correctly

    Code
      cat(readLines(out), sep = "\n")
    Output
      [Null
      ,Div ("",["objectives"],[])
       [Header 2 ("",[],[]) [Str "Overview"]
       ,Div ("",["row"],[])
        [Div ("",["col-md-3"],[])
         [Para [Strong [Str "Teaching: "],Space,Str "6",LineBreak,Strong [Str "Exercises: "],Space,Str "9"]]
        ,Div ("",["col-md-9"],[])
         [Para [Strong [Str "Questions"]]
         ,BulletList
          [[Plain [Str "What\8217s",Space,Str "the",Space,Str "point?"]]]]]
       ,Div ("",["row"],[])
        [Div ("",["col-md-3"],[])
         []
        ,Div ("",["col-md-9"],[])
         [Para [Strong [Str "Objectives"]]
         ,BulletList
          [[Plain [Str "Bake",Space,Str "him",Space,Str "away,",Space,Str "toys"]]]]]]
      ,Para [Str "Do",Space,Str "you",Space,Str "think",Space,Str "he",Space,Str "saurus?"]
      ,Header 1 ("markdown",[],[]) [Str "Markdown"]]

# render_html applies the internal lua filter

    Code
      cat(res)
    Output
      <div class="section level2 objectives">
      <h2>Overview</h2>
      <div class="row">
      <div class="col-md-3">
      <p><strong>Teaching: </strong> 6<br />
      <strong>Exercises: </strong> 9</p>
      </div>
      <div class="col-md-9">
      <p><strong>Questions</strong></p>
      <ul>
      <li>What’s the point?</li>
      </ul>
      </div>
      </div>
      <div class="row">
      <div class="col-md-3">
      
      </div>
      <div class="col-md-9">
      <p><strong>Objectives</strong></p>
      <ul>
      <li>Bake him away, toys</li>
      </ul>
      </div>
      </div>
      </div>
      <div id="markdown" class="section level1">
      <h1>Markdown</h1>
      <div class="challenge">
      <div class="section level2">
      <h2>Challenge</h2>
      <p>How do you write markdown divs?</p>
      <p>This <a href="Setup.html">link should be transformed</a></p>
      <p>This <a href="Setup.html#windows-setup" title="windows setup">too</a></p>
      <div class="figure">
      <img src="fig/Setup.png" alt="alt text" alt="" />
      <p class="caption">link should be transformed</p>
      </div>
      </div>
      <div id="write-now" class="section level2 solution">
      <h2>Write now</h2>
      <p>just write it, silly.</p>
      </div>
      </div>
      <aside class="instructor">
      <div>
      <p>This should be aside</p>
      </div>
      </aside>
      <div class="nothing">
      <p>This should be</p>
      </div>
      </div>

