local text = require('text')

-- Lua Set for checking existence of item
-- https://www.lua.org/pil/11.5.html
function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local blocks = {
  ["callout"] = "bell",
  ["objectives"] = "none",
  ["challenge"] = "zap",
  ["prereq"] = "check",
  ["checklist"] = "check-square",
  ["solution"] = "none",
  ["discussion"] = "message-circle",
  ["testimonial"] = "heart",
  ["keypoints"] = "key",
  ["instructor"] = "edit-2"
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
--]]
function overview_card()
  local res = pandoc.List:new{}
  local questions_div = pandoc.Div({}, {class='inner'})
  local objectives_div = pandoc.Div({}, {class='inner bordered'});
  local qbody = pandoc.Div({}, {class="card-body"})
  local obody = pandoc.Div({}, {class="card-body"})
  local qcol = pandoc.Div({}, {class="col-md-4"})
  local ocol = pandoc.Div({}, {class="col-md-8"})
  local row = pandoc.Div({}, {class="row g-0"})
  local overview = pandoc.Div({}, {class="overview card"})
  -- create headers. Note because of --section-divs, we have to insert raw
  -- headers so that the divs do not inherit the header classes afterwards
  table.insert(questions_div.content, 
    pandoc.RawBlock("html", "<h3 class='card-title'>Questions</h3>"))
  table.insert(objectives_div.content, 
    pandoc.RawBlock("html", "<h3 class='card-title'>Objectives</h3>"))

  -- Insert the content from the objectives and the questions
  for _, block in ipairs(objectives.content) do
    if block.t ~= "Header" then
      table.insert(objectives_div.content, block)
    end
  end
  for _, block in ipairs(questions.content) do
    if block.t ~= "Header" then
      table.insert(questions_div.content, block)
    end
  end

  -- Build the whole thing
  table.insert(qbody.content, questions_div)
  table.insert(obody.content, objectives_div)
  table.insert(qcol.content, qbody)
  table.insert(ocol.content, obody)
  table.insert(row.content, qcol) 
  table.insert(row.content, ocol) 
  table.insert(overview.content, 
    pandoc.RawBlock("html", "<h2 class='card-header'>Overview</h2>"))
  table.insert(overview.content, row)
  table.insert(res, overview)
  return(res)
end


function get_header(el, level)
  -- bail early if there is no class or it's not one of ours
  local no_class = el.classes[1] == nil
  if no_class then
    return nil
  end
  local class = pandoc.utils.stringify(el.classes[1])
  if blocks[class] == nil then
    return nil
  end
  -- check if the header exists
  local header = el.content[1]
  if header.level == nil then
    -- capitalize the first letter and insert it at the top of the block
    local C = text.upper(text.sub(class, 1, 1))
    local lass = text.sub(class, 2, -1)
    header = pandoc.Header(3, C..lass)
  else
    header.level = 3
    el.content:remove(1)
  end
  header.classes = {"callout-title"}
  return(header)
end

-- Add a header to a Div element if it doesn't exist
-- 
-- @param el a pandoc.Div element
-- @param level an integer specifying the level of the header
--
-- @return the element with a header if it doesn't exist
function level_head(el, level)

  -- bail early if there is no class or it's not one of ours
  local no_class = el.classes[1] == nil
  if no_class then
    return el
  end
  local class = pandoc.utils.stringify(el.classes[1])
  if blocks[class] == nil then
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

instructor_note = function(el)
-- <div class="accordion instructor-note accordion-flush" id="accordionFlushExample">
--   <div class="accordion-item">
--     <button class="accordion-button collapsed instructor-button" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseInstructor" aria-expanded="false" aria-controls="flush-collapseInstructor">
--       <h3 class="accordion-header" id="flush-headingInstructor">
--         <div class="note-square"><i aria-hidden="true" class="callout-icon" data-feather="edit-2"></i></div>Instructor Note
--       </h3>
--     </button>
--     <div id="flush-collapseInstructor" class="accordion-collapse collapse" aria-labelledby="flush-headingInstructor" data-bs-parent="#accordionFlushExample">
--       <div class="accordion-body">Placeholder content for this accordion, which is intended to demonstrate the <code>.accordion-flush</code> class. This is the first item's accordion body.</div>
--     </div>
--   </div>
-- </div>
  local header = get_header(el, 3)
  el.classes = {'accordion-body'}
  local accordion_collapse = pandoc.Div({el}, {class = "accordion-collapse collapse"})
  local button = pandoc.RawBlock("html", [[
    <button class="accordion-button collapsed instructor-button" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseInstructor" aria-expanded="false" aria-controls="flush-collapseInstructor">
      <h3 class="accordion-header" id="flush-headingInstructor">
        <div class="note-square"><i aria-hidden="true" class="callout-icon" data-feather="edit-2"></i></div>
        Instructor Note
      </h3>
    </button>
  ]])
  local accordion_item = pandoc.Div({button, accordion_collapse}, {class = "accordion-item"})
  -- TODO: add attributes to the accordion collapse
  local instructor_note = pandoc.Div({accordion_item}, {class = "accordion instructor-note accordion-flush"})
  return(instructor_note)
end


-- Deal with fenced divs
handle_our_divs = function(el)

  -- Questions and Objectives should be grouped
  v,i = el.classes:find("questions")
  if i ~= nil then
    questions = el
    if objectives ~= nil then
      return overview_card()
    else 
      return pandoc.Null()
    end
  end

  v,i = el.classes:find("objectives")
  if i ~= nil then
    objectives = el
    if questions ~= nil then
      return overview_card()
    else 
      return pandoc.Null()
    end
  end
  v,i = el.classes:find("instructor")
  if i ~= nil then
    return(instructor_note(el))
  end


  -- All other Div tags should have at most level 2 headers
  level_head(el, 3)
  local classes = el.classes:map(pandoc.utils.stringify)
  local this_icon = blocks[classes[1]]
  if this_icon == nil then
    return el
  end
  classes:insert(1, "callout")
  local header = get_header(el, 3)

  local icon = pandoc.RawBlock("html", 
    "<i class='callout-icon' data-feather='"..this_icon.."'></i>")
  local callout_square = pandoc.Div(icon, {class = "callout-square"})


  local callout_inner = pandoc.Div({header}, {class = "callout-inner"})

  el.classes = {"callout-content"}
  table.insert(callout_inner.content, el)
  local callout_block = pandoc.Div({callout_square, callout_inner})
  callout_block.classes = classes
  return(callout_block)
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
  local proto = text.sub(tgt, 1, 4)
  if proto ~= "http" and proto ~= "ftp:" then
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

provision_caption = function(el)
  el = flatten_links(el)
  el.classes = {"figure", "mx-auto", "d-block"}
  return(el)
end

return {
  {Meta  = get_timings},
  {Link  = flatten_links},
  {Image = flatten_links},
  {Div   = handle_our_divs}
}
