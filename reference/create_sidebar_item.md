# Create a single item that appears in the sidebar

Varnish uses a sidebar for navigation across and within an episode. This
funciton will create a sidebar item for a single episode, providing a
dropdown menu of the sections within the episode *if it is labeled as
the current episode*.

## Usage

``` r
create_sidebar_item(nodes, link, position)

create_sidebar_headings(nodes)
```

## Arguments

- nodes:

  html nodes of a webpage generated from
  [`render_html()`](https://carpentries.github.io/sandpaper/reference/render_html.md)
  or parsed from xml2 that have level 2 section headings with the class
  `section-heading`

- link:

  a character vector of length 1 that defines the HTML links to be used
  as the node for the sidebar item.

- position:

  either a number or "current", if "current", then the html is parsed
  for second level headings to list in the sidebar navigation.

## Value

a character vector with a div item to insert into the sidebar navigation

## Examples

``` r
snd <- asNamespace("sandpaper")
html <- c(
  "<section id='one'><h2 class='section-heading'>Section 1</h2><p>section 1</p></section>",
  "<section id='two'><h2 class='section-heading'>Section 2</h2><p>section 2</p></section>"
)
nodes <- xml2::read_html(paste(html, collapse = "\n"))

# The sidebar headings are extracted from the nodes
writeLines(snd$create_sidebar_headings(nodes))
#> <li><a href='#one'>Section 1</a></li>
#> <li><a href='#two'>Section 2</a></li>

link <- "<a href='https://example.com/this-page.html'><em>This Page</em></a>"

# the sidebar item will contain the headings if it is the current chapter
writeLines(snd$create_sidebar_item(nodes, link, position = "current"))
#> <div class="accordion accordion-flush" id="accordionFlushcurrent">
#>   <div class="accordion-item">
#>     <div class="accordion-header" id="flush-headingcurrent">
#>       <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapsecurrent" aria-expanded="true" aria-controls="flush-collapsecurrent">
#>         <span class="visually-hidden">Current Chapter</span>
#>         <span class="current-chapter">
#>         <a href='https://example.com/this-page.html'><em>This Page</em></a>
#>         </span>
#>       </button>
#>     </div><!--/div.accordion-header-->
#>         
#>     <div id="flush-collapsecurrent" class="accordion-collapse collapse show" aria-labelledby="flush-headingcurrent" data-bs-parent="#accordionFlushcurrent">
#>       <div class="accordion-body">
#>         <ul>
#>           <li><a href='#one'>Section 1</a></li>
#> <li><a href='#two'>Section 2</a></li>
#>         </ul>
#>       </div><!--/div.accordion-body-->
#>     </div><!--/div.accordion-collapse-->
#>         
#>   </div><!--/div.accordion-item-->
#> </div><!--/div.accordion-flush-->
#> 

# it will be an ordinary link otherwise
writeLines(snd$create_sidebar_item(nodes, link, position = 3))
#> <div class="accordion accordion-flush" id="accordionFlush3">
#>   <div class="accordion-item">
#>     <div class="accordion-header" id="flush-heading3">
#>         <a href='https://example.com/this-page.html'><em>This Page</em></a>
#>     </div><!--/div.accordion-header-->
#>         
#>   </div><!--/div.accordion-item-->
#> </div><!--/div.accordion-flush-->
#> 
```
