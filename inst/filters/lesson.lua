-- Convert Div elements to semantic HTML <aside> tags
--
-- NOTE: This destructively converts div tags, so do not apply this to a div
-- tag that has more than one associated class.
--
-- @param el a pandoc Div element
-- @param i the index of the class element
-- 
-- @return a pandoc List element, with the contents of the Div block surrounded 
-- by opening and closing <aside> html elements
function step_aside(el, i)
  -- create a new pandoc element, add raw HTML, 
  -- and fill it with the content of the div block
  local class = el.classes[i]
  local html
  local res = pandoc.List:new{}

  -- remove this class from the div tag
  el.classes[i] = nil

  -- Step 1: insert the HTML opening tag
  html = '<aside class="'..class..'">'

  table.insert(res, pandoc.RawBlock('html', html))

  -- Step 2: insert the content of the Div block into the output List
  for _, block in ipairs(el.content) do
    table.insert(res, block)
  end
  
  -- Step 3: insert the HTML closing tag
  table.insert(res, pandoc.RawBlock('html', '</aside>'))

  return res
end

local text = require('text')
-- Add a header to a Div element if it doesn't exist
-- 
-- @param el a pandoc.Div element
--
-- @return the element with a header if it doesn't exist
function head_of_the_class(el)

  -- bail early if there is no class
  local class = el.classes[1]
  if class == nil then
    return el
  end

  -- check if the header exists
  local header = el.content[1].level
  if header == nil then
    -- capitalize the first letter and insert it at the top of the block
    local C = text.upper(text.sub(class, 1, 1))
    local lass = text.sub(class, 2, -1)
    el.content:insert(1, pandoc.Header(2, C..lass))
  elseif header ~= 2 then
    -- force the header level to be 2
    el.content[1].level = 2
  end

  return el
end

-- Deal with fenced divs
Div = function(el)

  -- Instructor notes should be aside tags
  v,i = el.classes:find("instructor")
  if i ~= nil then
    return step_aside(el, i)
  end

  -- All other Div tags should have level 2 headers
  head_of_the_class(el)

  -- Callouts should be asides
  v,i = el.classes:find("callout")
  if i ~= nil then
    return step_aside(el, i)
  end

  return el
end

