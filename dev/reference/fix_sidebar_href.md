# Fix the refs for a vector of sidebar nodes

update links from a list of HTML node

## Usage

``` r
fix_sidebar_href(
  item,
  path = NULL,
  scheme = NULL,
  server = NULL,
  query = NULL,
  fragment = NULL
)

make_url(parsed)

append(first, sep = "#", last, trim = TRUE)
```

## Arguments

- item:

  a text representation of HTML nodes that contain `<a>` elements.

- path, scheme, server, query, fragment:

  character vectors of elements to replace. This can be a single element
  vector, which will be recycled or a vector with the same length as
  `item`.

- parsed:

  a data frame produced via
  [xml2::url_parse](http://xml2.r-lib.org/reference/url_parse.md)

- first:

  a character vector

- sep:

  a character vector of length 1

- last:

  a character vector, same length as `first` or length 1

- trim:

  a logical indicating if the leading and trailing `sep` should be
  trimmed from `first` and `last`.

## Value

the text representation of HTML nodes with the `href` element modified.

## Details

Repeat after me: parsing HTML with regular expressions is bad. This
function uses
[`xml2::read_html()`](http://xml2.r-lib.org/reference/read_xml.md) to
parse incoming HTML content to convert the HTML string into an XML
document where we can extract all of the anchor links, parse them and
replace their contents without regex. This is acheived via
[`xml2::url_parse()`](http://xml2.r-lib.org/reference/url_parse.md)
separating the URL into pieces and updating those pieces for each node.

`fix_sidebar_href()` is useful because The sidebar nodes needs to be
updated for the 404 page so that all links use the published URL. NOTE:
this does not take into account `port` or `user`.

The auxilary functions `make_url()`, `append()` and `prepend()` are used
to convert the output of
[`xml2::url_parse()`](http://xml2.r-lib.org/reference/url_parse.md) back
to a URL.

## Examples

``` r
my_links <- c(
  "<div id='one'><div id='one-one'><a href='index.html'>Index</a></div></div>",
  "<div id='two'><div id='two-two'><a href='two.html'><em>Two</em></a></div></div>",
  "<div id='three'><div id='three-three'><a href='three.html'>Three</a></div></div>",
  "<div id='four'><div id='four-four'><a href='four.html'>Four</a></div></div>",
  "<div id='five'><div id='five-five'><a href='five.html'>Five</a></div></div>"
)

snd <- asNamespace("sandpaper")
# Prepend a server to the links
snd$fix_sidebar_href(my_links, scheme = "https", server = "example.com")
#> [1] "<div id=\"one\"><div id=\"one-one\"><a href=\"https://example.com/index.html\">Index</a></div></div>"      
#> [2] "<div id=\"two\"><div id=\"two-two\"><a href=\"https://example.com/two.html\"><em>Two</em></a></div></div>" 
#> [3] "<div id=\"three\"><div id=\"three-three\"><a href=\"https://example.com/three.html\">Three</a></div></div>"
#> [4] "<div id=\"four\"><div id=\"four-four\"><a href=\"https://example.com/four.html\">Four</a></div></div>"     
#> [5] "<div id=\"five\"><div id=\"five-five\"><a href=\"https://example.com/five.html\">Five</a></div></div>"     
snd$fix_sidebar_href(my_links, server = "https://example.com")
#> [1] "<div id=\"one\"><div id=\"one-one\"><a href=\"https://example.com/index.html\">Index</a></div></div>"      
#> [2] "<div id=\"two\"><div id=\"two-two\"><a href=\"https://example.com/two.html\"><em>Two</em></a></div></div>" 
#> [3] "<div id=\"three\"><div id=\"three-three\"><a href=\"https://example.com/three.html\">Three</a></div></div>"
#> [4] "<div id=\"four\"><div id=\"four-four\"><a href=\"https://example.com/four.html\">Four</a></div></div>"     
#> [5] "<div id=\"five\"><div id=\"five-five\"><a href=\"https://example.com/five.html\">Five</a></div></div>"     


# Add an anchor to the links
snd$fix_sidebar_href(my_links, scheme = "https", fragment = "anchor")
#> [1] "<div id=\"one\"><div id=\"one-one\"><a href=\"https://index.html#anchor\">Index</a></div></div>"      
#> [2] "<div id=\"two\"><div id=\"two-two\"><a href=\"https://two.html#anchor\"><em>Two</em></a></div></div>" 
#> [3] "<div id=\"three\"><div id=\"three-three\"><a href=\"https://three.html#anchor\">Three</a></div></div>"
#> [4] "<div id=\"four\"><div id=\"four-four\"><a href=\"https://four.html#anchor\">Four</a></div></div>"     
#> [5] "<div id=\"five\"><div id=\"five-five\"><a href=\"https://five.html#anchor\">Five</a></div></div>"     

# NOTE: this will _always_ return a character vector, even if the input is
# incorrect
snd$fix_sidebar_href(list(), server = "example.com")
#> [1] ""
```
