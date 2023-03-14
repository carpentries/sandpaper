# paths in instructor view that are nested or not HTML get diverted

    Code
      xml2::xml_find_all(html_test, ".//a[@href]")
    Output
      {xml_nodeset (10)}
       [1] <a href="index.html">a</a>
       [2] <a href="./index.html">b</a>
       [3] <a href="fig/thing.png">c</a>
       [4] <a href="./fig/thang.jpg">d</a>
       [5] <a href="data/thing.csv">e</a>
       [6] <a href="files/papers/thing.pdf">f</a>
       [7] <a href="files/confirmation.html">g</a>
       [8] <a href="#what-the">h</a>
       [9] <a href="other-page.html#section">i</a>
      [10] <a href="other-page">j</a>

---

    Code
      xml2::xml_find_all(res, ".//a[@href]")
    Output
      {xml_nodeset (10)}
       [1] <a href="index.html">a</a>
       [2] <a href="./index.html">b</a>
       [3] <a href="../fig/thing.png">c</a>
       [4] <a href=".././fig/thang.jpg">d</a>
       [5] <a href="../data/thing.csv">e</a>
       [6] <a href="../files/papers/thing.pdf">f</a>
       [7] <a href="../files/confirmation.html">g</a>
       [8] <a href="#what-the">h</a>
       [9] <a href="other-page.html#section">i</a>
      [10] <a href="other-page">j</a>

