local text = require('text')

-- Lua Set for checking existence of item
-- https://www.lua.org/pil/11.5.html
function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
local blocks = Set{
  "callout",
  "objectives",
  "challenge",
  "prereq",
  "checklist",
  "solution",
  "discussion",
  "testimonial",
  "keypoints",
}

-- get the timing elements from the metadata and store them in a global var
local timings = {}
local questions
local objectives
function get_timings (meta)
  for k, v in pairs(meta) do
    if type(v) == 'table' and v.t == 'MetaInlines' then
      timings[k] = {table.unpack(v)}
    end
  end
end

--[[
-- TODO: Create combination Timings, Questions, and Objectives block:
--
-- This block in practice looks like this, but I think it could probably be
-- improved.
--
-- <div class="objectives">
--   <div class="row">
--     <div class="col-md-3">
--       pandoc.Strong { pandoc.Str "Teaching:" } timings["teaching"]..
--       pandoc.LineBreak..
--       pandoc.Strong { pandoc.Str "Exercises:" } timings["exercises"]
--     </div>
--     <div class="col-md-9">
--       pandoc.Strong { pandoc.Str "Questions" }..
--       pandoc.LineBreak..
--       pandoc.BulletList {  }
--     </div>
--   </div>
--   <div class="row">
--     <div class="col-md-3">
--     </div>
--     <div class="col-md-9">
--       pandoc.Strong { pandoc.Str "Objectives" }..
--       pandoc.LineBreak..
--       pandoc.BulletList {  }
--     </div>
--   </div>
-- </div>
--]]
function first_block()
  local res = pandoc.List:new{}
  local html_open
  local html_col9
  local html_close
  local teach = pandoc.utils.stringify(timings["teaching"])
  local exercise = pandoc.utils.stringify(timings["exercises"])
  html_open = pandoc.RawBlock('html', [[
  <div class="row">
    <div class="col-md-3">
  ]])
  html_col9 = pandoc.RawBlock('html', [[
    </div>
    <div class="col-md-9">
  ]])
  html_close = pandoc.RawBlock('html', [[
    </div>
  </div>
  ]])
  table.insert(res, pandoc.RawBlock('html', '<div class="objectives">'))
  table.insert(res, pandoc.Header(2, "Overview"))
  table.insert(res, html_open)
  texercises = pandoc.List:new{
    pandoc.Strong {pandoc.Str "Teaching: "},
    pandoc.Space(),
    pandoc.Str(teach),
    pandoc.LineBreak(),
    pandoc.Strong {pandoc.Str "Exercises: "},
    pandoc.Space(),
    pandoc.Str(exercise),
  }
  table.insert(res, pandoc.Para(texercises))
  table.insert(res, html_col9)
  table.insert(res, pandoc.Para(pandoc.List:new {
    pandoc.Strong {pandoc.Str "Questions"}
  }))
  for _, block in ipairs(questions.content) do
    table.insert(res, block)
  end
  table.insert(res, html_close)
  table.insert(res, html_open)
  table.insert(res, html_col9)
  table.insert(res, pandoc.Para(pandoc.List:new {
    pandoc.Strong {pandoc.Str "Objectives"}
  }))
  for _, block in ipairs(objectives.content) do
    table.insert(res, block)
  end
  table.insert(res, html_close)
  table.insert(res, pandoc.RawBlock('html', '</div>'))
  return(res)
end

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

-- Add a header to a Div element if it doesn't exist
-- 
-- @param el a pandoc.Div element
--
-- @return the element with a header if it doesn't exist
function head_of_the_class(el)

  -- bail early if there is no class or it's not one of ours
  local class = pandoc.utils.stringify(el.classes[1])
  if class == nil or blocks[class] == nil then
    return el
  end

  -- check if the header exists
  local header = el.content[1].level
  if header == nil then
    -- capitalize the first letter and insert it at the top of the block
    local C = text.upper(text.sub(class, 1, 1))
    local lass = text.sub(class, 2, -1)
    local header = pandoc.Header(2, C..lass)
    table.insert(el.content, 1, header)
  end

  if header ~= 2 then
    -- force the header level to be 2
    el.content[1].level = 2
  end

  return el
end


-- Deal with fenced divs
handle_our_divs = function(el)

  -- Questions and Objectives should be grouped
  v,i = el.classes:find("questions")
  if i ~= nil then
    questions = el
    if objectives ~= nil then
      return first_block()
    end
  end

  v,i = el.classes:find("objectives")
  if i ~= nil then
    objectives = el
    if questions ~= nil then
      return first_block()
    end
  end

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

return {
  {Meta = get_timings},
  {Div = handle_our_divs}
}
