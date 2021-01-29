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
-- Create Overview block that is a combination of questions and objectives.
--
-- This was originally taken care of by Jekyll, but since we are not necessarily
-- relying on a logic-based templating language (liquid can diaf), we can create
-- this here. 
--
-- This relies on a couple of things
--
-- Meta: teaching and exercises
-- Body: questions and objectives. 
--]]
function first_block()
  local res = pandoc.List:new{}
  local teach = pandoc.utils.stringify(timings["teaching"])
  local exercise = pandoc.utils.stringify(timings["exercises"])

  -- The objectives block has six divs nested inside of it 
  -- (
  --  ( ()() )
  --  ( ()() )
  -- )
  -- We are creating the div blocks, inserting the content, and then nesting
  -- them inside each other before adding them to the block. 
  local objectives_div = pandoc.Div({}, {class='objectives'});
  local row1 = pandoc.Div({}, {class='row'});
  local row2 = pandoc.Div({}, {class='row'});
  local row1_left_col = pandoc.Div({}, {class='col-md-3'});
  local row1_right_col = pandoc.Div({}, {class='col-md-9'});
  local row2_left_col = pandoc.Div({}, {class='col-md-3'});
  local row2_right_col = pandoc.Div({}, {class='col-md-9'});

  -- ## Objectives
  table.insert(objectives_div.content, pandoc.Header(2, "Overview"))

  -- Teaching: NN
  -- Objectives: NN
  texercises = pandoc.List:new{
    pandoc.Strong {pandoc.Str "Teaching: "},
    pandoc.Space(),
    pandoc.Str(teach),
    pandoc.LineBreak(),
    pandoc.Strong {pandoc.Str "Exercises: "},
    pandoc.Space(),
    pandoc.Str(exercise),
  }
  table.insert(row1_left_col.content, pandoc.Para(texercises))

  -- **Questions**
  --
  -- - What?
  -- - Who?
  -- - Why?
  table.insert(row1_right_col.content, pandoc.Para(pandoc.List:new {
    pandoc.Strong {pandoc.Str "Questions"}
  }))
  for _, block in ipairs(questions.content) do
    table.insert(row1_right_col.content, block)
  end

  -- **Objectives**
  --
  -- - S3
  -- - S4
  -- - R6
  table.insert(row2_right_col.content, pandoc.Para(pandoc.List:new {
    pandoc.Strong {pandoc.Str "Objectives"}
  }));
  for _, block in ipairs(objectives.content) do
    table.insert(row2_right_col.content, block);
  end

  -- Adding columns to rows
  table.insert(row1.content, row1_left_col);
  table.insert(row1.content, row1_right_col);
  table.insert(row2.content, row2_left_col);
  table.insert(row2.content, row2_right_col);
  
  -- Adding rows to div
  table.insert(objectives_div.content, row1);
  table.insert(objectives_div.content, row2);

  -- Adding div to main table
  table.insert(res, objectives_div)

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
    else 
      return pandoc.Null()
    end
  end

  v,i = el.classes:find("objectives")
  if i ~= nil then
    objectives = el
    if questions ~= nil then
      return first_block()
    else 
      return pandoc.Null()
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
