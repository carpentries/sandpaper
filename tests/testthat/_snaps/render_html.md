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

