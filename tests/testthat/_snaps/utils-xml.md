# paths in instructor view that are nested or not HTML get diverted

    Code
      xml2::xml_find_all(html_test, ".//a")
    Output
      {xml_nodeset (7)}
      [1] <a href="index.html">a</a>
      [2] <a href="./index.html">b</a>
      [3] <a href="fig/thing.png">c</a>
      [4] <a href="./fig/thang.jpg">d</a>
      [5] <a href="data/thing.csv">e</a>
      [6] <a href="files/papers/thing.pdf">f</a>
      [7] <a href="files/confirmation.html">g</a>

---

    Code
      xml2::xml_find_all(res, ".//a")
    Output
      {xml_nodeset (7)}
      [1] <a href="index.html">a</a>
      [2] <a href="./index.html">b</a>
      [3] <a href="../fig/thing.png">c</a>
      [4] <a href=".././fig/thang.jpg">d</a>
      [5] <a href="../data/thing.csv">e</a>
      [6] <a href="../files/papers/thing.pdf">f</a>
      [7] <a href="../files/confirmation.html">g</a>

