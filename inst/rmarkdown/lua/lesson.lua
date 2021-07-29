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
    if block.t ~= "Header" then
      table.insert(row1_right_col.content, block)
    end
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
    if block.t ~= "Header" then
      table.insert(row2_right_col.content, block);
    end
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
  -- need an inner div to make sure that headers are not accidentally runed
  local inner_div = pandoc.Div({});
  local res = pandoc.List:new{}

  -- remove this class from the div tag
  el.classes[i] = nil

  -- Step 1: insert the HTML opening tag
  html = '<aside class="'..class..'">'

  table.insert(res, pandoc.RawBlock('html', html))

  -- Step 2: insert the content of the Div block into the output List
  for _, block in ipairs(el.content) do
    table.insert(inner_div.content, block)
  end

  -- Step 3: insert div block
  table.insert(res, inner_div);
  -- Step 4: insert the HTML closing tag
  table.insert(res, pandoc.RawBlock('html', '</aside>'))

  return res
end

-- Add a header to a Div element if it doesn't exist
-- 
-- @param el a pandoc.Div element
-- @param level an integer specifying the level of the header
--
-- @return the element with a header if it doesn't exist
function level_head(el, level)

  -- bail early if there is no class or it's not one of ours
  local class = pandoc.utils.stringify(el.classes[1])
  if class == nil or blocks[class] == nil then
    return el
  end

  -- check if the header exists
  local id = 1
  local header = el.content[id]

  if level ~= 0 and header.level == nil then
    -- capitalize the first letter and insert it at the top of the block
    local C = text.upper(text.sub(class, 1, 1))
    local lass = text.sub(class, 2, -1)
    local header = pandoc.Header(level, C..lass)
    table.insert(el.content, id, header)
  end

  if level == 0 and header.level ~= nil then
    el.content:remove(id)
  end

  if header.level ~= nil and header.level < level then
    -- force the header level to increase
    el.content[id].level = level
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
    level_head(el, 3) -- force level to be at most 3
    return step_aside(el, i) -- create aside padding
  end

  -- Callouts should be asides
  -- 2021-01-29: There is still a persistent issue with --section-divs if there
  -- is a header in the aside tag. Because --section-divs will take a header and
  -- figure collapse everything until the next header of equal or greater value
  -- into a section and it does not interpret asides as a valid section, it
  -- will close the previous section after the aside tag because it assumes that
  -- the aside belongs to the previous section (which it kind of does). Example:
  --
  -- <section id="this-should-be-in-the-main-content" class="level2">
  -- <h2>This should be in the main content</h2>
  -- <p>There usually is text before a callout.</p>
  -- <aside class="callout">
  --> </section> <-- section closes here, trapping the initial aside tag
  -- <section id="main-aside" class="level1">
  -- <h1>Main Aside</h1>
  -- <p>This should be <code>&lt;aside&gt;</code>, but appear in the main body.</p>
  -- </section>
  -- </aside>
  --
  v,i = el.classes:find("callout")
  if i ~= nil then
    level_head(el, 3) -- force level to be at most 3
    return step_aside(el, i) -- create aside padding
  end

  -- When I finally know how to manipulate jquery, I can implement this, but
  -- for now, they will remain at level 2 :(
  -- v,i = el.classes:find("solution")
  -- if i ~= nil then
  --   level_head(el, 3) -- force level to be at most 3
  --   return el
  -- end

  -- All other Div tags should have at most level 2 headers
  level_head(el, 2)

  return el
end

-- Flatten relative links for HTML output
--
-- 1. removes any leading ../[folder]/ from the links to prepare them for the
--    way the resources appear in the HTML site
-- 2. renames all local Rmd and md files to .html 
--
-- NOTE: it _IS_ possible to use variable expansion with this so that we can
--       configure this to do specific things (e.g. decide how we want the
--       architecture of the final site to be)
-- function expand (s)
--   s = s:gsub("$(%w+)", function(n)
--      return _G[n] -- substitute with global variable
--   end)
--   return s
-- end
flatten_links = function(el)
  local pat = "^%.%./"
  local tgt;
  if el.target == nil then
    tgt = el.src
  else
    tgt = el.target
  end
  -- Flatten local redirects, e.ge. ../episodes/link.md goes to link.md
  tgt,_ = tgt:gsub(pat.."episodes/", "")
  tgt,_ = tgt:gsub(pat.."learners/", "")
  tgt,_ = tgt:gsub(pat.."instructors/", "")
  tgt,_ = tgt:gsub(pat.."profiles/", "")
  tgt,_ = tgt:gsub(pat, "")
  -- rename local markdown/Rmarkdown
  -- link.md goes to link.html
  -- link.md#section1 goes to link.html#section1
  if text.sub(tgt, 1, 5) ~= "http"  then
    tgt,_ = tgt:gsub("%.R?md(#[%S]+)$", ".html%1")
    tgt,_ = tgt:gsub("%.R?md$", ".html")
  end
  if el.target == nil then
    el.src = tgt;
  else
    el.target = tgt;
  end
  return el
end

return {
  {Meta  = get_timings},
  {Link  = flatten_links},
  {Image = flatten_links},
  {Div   = handle_our_divs}
}
