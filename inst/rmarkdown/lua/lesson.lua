PANDOC_VERSION:must_be_at_least '2.11'
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
  ["caution"] = "alert-triangle",
  ["objectives"] = "none",
  ["challenge"] = "zap",
  ["prereq"] = "check",
  ["checklist"] = "check-square",
  ["solution"] = "none",
  ["hint"] = "none",
  ["spoiler"] = "eye",
  ["discussion"] = "message-circle",
  ["testimonial"] = "heart",
  ["keypoints"] = "key",
  ["instructor"] = "edit-2",
  ["tab"] = "none",
  ["group-tab"] = "none"
}

local block_counts = {
  ["callout"] = 0,
  ["caution"] = 0,
  ["objectives"] = 0,
  ["challenge"] = 0,
  ["prereq"] = 0,
  ["checklist"] = 0,
  ["solution"] = 0,
  ["hint"] = 0,
  ["spoiler"] = 0,
  ["discussion"] = 0,
  ["testimonial"] = 0,
  ["keypoints"] = 0,
  ["instructor"] = 0,
  ["tab"] = 0,
  ["group-tab"] = 0
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
  if header == nil or header.level == nil then
    -- capitalize the first letter and insert it at the top of the block
    header = pandoc.Header(3, upper_case(class))
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

  -- fix for https://github.com/carpentries/sandpaper/issues/581
  if header == nil then
    return el
  end

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


local button_headings = {
  ["instructor"] = [[
  <h3 class="accordion-header" id="heading{{id}}">
  <div class="note-square"><i aria-hidden="true" class="callout-icon" data-feather="edit-2"></i></div>
  {{title}}
  </h3>]],
  ["challenge"] = [[
  <h4 class="accordion-header" id="heading{{id}}">
  {{title}}
  </h4>]],
  ["caution"] = [[
    <h4 class="accordion-header" id="heading{{id}}">
    {{title}}
    </h4>]],
  ["hint"] = [[
  <h4 class="accordion-header" id="heading{{id}}">
  {{title}}
  </h4>]],
  ["solution"] = [[
  <h4 class="accordion-header" id="heading{{id}}">
  {{title}}
  </h4>]],
  ["spoiler"] = [[
  <h3 class="accordion-header" id="heading{{id}}">
  <div class="note-square"><i aria-hidden="true" class="callout-icon" data-feather="eye"></i></div>
  {{title}}
  </h3>]],
  ["tab"] = [[
  <h3 class="tab-header" id="nav-tab-heading-{{id}}">
  {{title}}
  </h3>]],
}

local accordion_titles = {
  ["instructor"] = "Instructor Note",
  ["hint"] = "Give me a hint",
  ["solution"] = "Show me the solution",
  ["spoiler"] = "Show details"
}

local accordion_button = [[
<button class="accordion-button {{class}}-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse{{id}}" aria-expanded="false" aria-controls="collapse{{id}}">
{{heading}}
</button>]]

upper_case = function(txt)
  local C = text.upper(text.sub(txt, 1, 1))
  local apitalise = text.sub(txt, 2, -1)
  return C..apitalise
end

accordion = function(el, class)

  block_counts[class] = block_counts[class] + 1

  local id    = block_counts[class]
  local CLASS = upper_case(class)
  local label = CLASS..id
  local title = ""
  for _, ing in ipairs(get_header(el, 4).content) do
    title = title..pandoc.utils.stringify(ing)
  end
  if title == CLASS or title == nil or title == "" then
    title = accordion_titles[class]
  end

  -- constructing the button that contains a heading
  local this_button = accordion_button
  this_button = this_button:gsub("{{heading}}", button_headings[class])
  this_button = this_button:gsub("{{title}}", title)
  this_button = this_button:gsub("{{class}}", class)
  this_button = this_button:gsub("{{id}}", label)
  collapse_id = "collapse"..CLASS..id
  heading_id  = "heading"..CLASS..id
  div_id      = "accordion"..CLASS..id

  -- construct the divs... three of them that wrap the class div
  el.classes = {'accordion-body'}
  -- button that is the friend of the collapse
  local button = pandoc.RawBlock("html", this_button)

  -- div for collapsing content
  local accordion_collapse = pandoc.Div({el})
  -- n.b. in pandoc 2.17, the attributes must be set after the classes
  accordion_collapse.classes = {"accordion-collapse", "collapse"}
  accordion_collapse.identifier = collapse_id
  accordion_collapse.attributes = {
    ['aria-labelledby'] = heading_id,
    ['data-bs-parent'] = "#"..div_id,
  }
  -- the actual block to collapse things
  local accordion_item = pandoc.Div({button, accordion_collapse})
  accordion_item.classes = {"accordion-item"}
  -- accordion_item.attr = {['class'] = "accordion-item"}
  -- the whole package
  local main_div = pandoc.Div({accordion_item})
  local main_class = {"accordion", "instructor-note", "accordion-flush"}
  if class == "spoiler" then
    main_class[2] = "spoiler-accordion"
  elseif class ~= "instructor" then
    main_class[2] = "challenge-accordion"
  end
  main_div.identifier = div_id
  main_div.classes = main_class
  return(main_div)
end

-- For a single tab block:
-- Store the current tab button number
local tab_button_num = 0
-- Store the tab button number a tabpanel
-- element thinks it is on
local tabpanel_tab_button_num = 1

-- Stores the tab nav buttons
local tab_buttons = {}
-- Stores the elements to form the tabpanel
-- content for the tab currently being processed
local this_tab_tabpanel = {}
-- Stores a tab blocks, tabpanel content
local tabpanels = {}

-- Are we processing a group-tab?
local group_tab = false
local group_tab_titles = {}

local tab_button = [[
<button class="nav-link" id="nav-tab-{{id}}" {{name}} data-bs-toggle="tab" data-bs-target="#nav-tabpanel-{{id}}" type="button" role="tab" aria-controls="nav-tabpanel-{{id}}" aria-selected="false">
{{heading}}
</button>]]

-- The first tab button is active
local tab_button_active = [[
<button class="nav-link active" id="nav-tab-{{id}}" {{name}} data-bs-toggle="tab" data-bs-target="#nav-tabpanel-{{id}}" type="button" role="tab" aria-controls="nav-tabpanel-{{id}}" aria-selected="true">
{{heading}}
</button>]]

add_to_tabpanel = function(el)
  -- If the tabpanel_button_number is the same
  -- as the nav tab_button_number this element
  -- belongs with the current nav button so store
  -- it for later
  if tabpanel_tab_button_num == tab_button_num then
    table.insert(this_tab_tabpanel, el)
  -- Else we have hit the next tab button and should
  -- wrap the tabpanel content we stored in the
  -- this_tab_tabpanel table for the previous button
  else
    local id
    if group_tab then
      local tab_id = block_counts["group-tab"]
      id = tab_id.."-"..group_tab_titles[tabpanel_tab_button_num]
    else
      local tab_id = block_counts["tab"]
      id = tab_id.."-"..tabpanel_tab_button_num
    end

    -- Wrap the tabpanel contents in a div
    local tabpanel_div = pandoc.Div(this_tab_tabpanel)
    -- n.b. in pandoc 2.17, the attributes must be set after the classes
    if tabpanel_tab_button_num == 1 then
      tabpanel_div.classes = {"tab-pane show active"}
    else
      tabpanel_div.classes = {"tab-pane"}
    end
    tabpanel_div.identifier = "nav-tabpanel-"..id
    tabpanel_div.attributes = {
      ['role'] = 'tabpanel',
      ['aria-labelledby'] = "nav-tab-"..id,
    }

    -- Store the div for the tab_block function
    table.insert(tabpanels, tabpanel_div)

    -- We move onto the next button having processed
    -- the previous buttons tabpanel content
    tabpanel_tab_button_num = tabpanel_tab_button_num + 1

    -- The current element belongs to the new button
    -- so empty out the this_tab_tabpanel table and store the el
    this_tab_tabpanel = {}
    table.insert(this_tab_tabpanel, el)
  end
end

tab_filter = {
  Header = function(el)
    -- Level 3 headers mark the tab titles
    -- all other headers in a tab block are ignored
    if el.level == 3 then

      -- Insert the title for the add_to_tabpanel to access
      local title = pandoc.utils.stringify(el)

      local id
      local name
      if group_tab then
        local tab_id = block_counts["group-tab"]
        local title_no_spaces = title:gsub("%s+", "")
        id = tab_id.."-"..title_no_spaces
        -- The JS for the group tabs selects buttons
        -- to show based on the name attribute.
        -- Here we set it to the button title.
        name = 'name="'..title_no_spaces..'"'
        -- Store the title so it can be used in the tabpanel id
        table.insert(group_tab_titles, title_no_spaces)
      else
        local tab_id = block_counts["tab"]
        id = tab_id.."-"..tab_button_num+1
        -- Non group tabs don't need a name attribute.
        name = ""
      end

      -- Found another button so increment the
      -- current tab_button_num
      tab_button_num = tab_button_num + 1

      -- Create the button, if this is the first
      -- button it needs to be active
      local this_button
      if tab_button_num == 1 then
        this_button = tab_button_active
      else
        this_button = tab_button
      end

      -- Substitute in the button information
      this_button = this_button:gsub("{{heading}}", button_headings["tab"])
      this_button = this_button:gsub("{{title}}", title)
      this_button = this_button:gsub("{{id}}", id)
      this_button = this_button:gsub("{{name}}", name)

      -- Convert the tab button to a raw block and store
      local button = pandoc.RawBlock("html", this_button)
      table.insert(tab_buttons, button)
    end
  end,
  -- for all other elements process them using
  -- the add_to_tabpanel function
  Para = function(el)
    _ = add_to_tabpanel(el)
  end,
  Div = function(el)
    _ = add_to_tabpanel(el)
  end,
  Figure = function(el)
    _ = add_to_tabpanel(el)
  end,
  CodeBlock = function(el)
    _ = add_to_tabpanel(el)
  end,
  OrderedList = function(el)
    _ = add_to_tabpanel(el)
  end,
  BulletList = function(el)
    _ = add_to_tabpanel(el)
  end
}

tab_block = function(el)

  -- Increment the tab count
  local count
  if group_tab then
    block_counts["group-tab"] = block_counts["group-tab"] + 1
    count = block_counts["group-tab"]
  else
    block_counts["tab"] = block_counts["tab"] + 1
    count = block_counts["tab"]
  end

  -- Walk the tab elements and process them
  _ = pandoc.walk_block(el,tab_filter)

  -- Wraps the tab buttons to create the tablist div
  local button_div_id = "nav-tab-"..count
  local button_div = pandoc.Div(tab_buttons)
  button_div.identifier = button_div_id
  button_div.classes = {"nav", "nav-tabs"}
  button_div.attributes = {
    ['role'] = 'tablist',
  }

  -- The tab_filter uses the current tab number
  -- to determine whether we have reached the next tab
  -- This tricks the add_to_tabpanel function into thinking
  -- it has hit the number of tabs + 1 so it wraps
  -- the last tabpanel in a div
  tab_button_num = tab_button_num + 1
  _ = add_to_tabpanel(tabpanels)

  -- Wraps the tabpanels
  local tab_content_div = pandoc.Div(tabpanels)
  local tab_content_div_id = "nav-tabContent-"..count
  tab_content_div.identifier = tab_content_div_id
  tab_content_div.classes = {"tab-content"}

  -- Create the nav html tags
  local nav_start = pandoc.RawBlock("html", "<nav>")
  local nav_end = pandoc.RawBlock("html", "</nav>")

  -- Put everything in a tabs div
  local tabs = pandoc.Div({nav_start, button_div, nav_end, tab_content_div})
  tabs.classes = {"tabs"}

  -- Reset counters for the next tab block
  tab_button_num = 0
  tabpanel_tab_button_num = 1
  tab_buttons = {}
  this_tab_tabpanel = {}
  tabpanels = {}

  return tabs
end

callout_block = function(el)
  local classes = el.classes:map(pandoc.utils.stringify)
  local this_icon = blocks[classes[1]]
  if this_icon == nil then
    return el
  end
  -- Get the header and create the ID
  local header = get_header(el, 3)

  block_counts[classes[1]] = block_counts[classes[1]] + 1
  callout_id = classes[1]..block_counts[classes[1]]
  classes:insert(1, "callout")

  local icon = pandoc.RawBlock("html",
  "<i class='callout-icon' data-feather='"..this_icon.."'></i>")
  local callout_square = pandoc.Div(icon, {class = "callout-square"})

  local callout_inner = pandoc.Div({header}, {class = "callout-inner"})

  el.classes = {"callout-content"}
  table.insert(callout_inner.content, el)

  local block = pandoc.Div({callout_square, callout_inner})
  block.identifier = callout_id
  block.classes = classes
  return block
end

challenge_block = function(el)
  -- The challenge blocks no longer contain solutions nested inside. Instead,
  -- the solutions (and hints) are piled at the end of the block, so series of
  -- challenge/solutions need to be separated.

  -- The challenge train is a list to contain all the divs
  local challenge_train = pandoc.List:new()
  -- If the challenge contains multiple solutions or hints, we need to indicate
  -- that the following challenges/solutions are continuations.
  local this_head = get_header(el, 3)
  local next_head = this_head:clone()
  next_head.content:insert(pandoc.Emph(" (continued)"))
  next_head.classes = {"callout-title"}
  -- This challenge is a placeholder to stuff the original challenge contents in
  local this_challenge = pandoc.Div({this_head}, {class = "challenge"})
  -- Indicator if the challenge block should be inserted before the accordion.
  -- Once we hit an accordion block, we no longer need the challenge inserted
  -- and any new challenge items go in a new block
  local needs_challenge = true
  for idx, block in ipairs(el.content) do
    if block.classes ~= nil and block.classes[1] == "accordion" then
      if needs_challenge then
        challenge_train:insert(callout_block(this_challenge))
        this_challenge = pandoc.Div({next_head}, {class = "challenge"})
        needs_challenge = false
      end
      challenge_train:insert(block)
    else
      if block.t == "Header" and #this_challenge.content == 1 then
        -- if we started a new challenge block and it already has a header,
        -- then we need to remove our continuation header
        this_challenge.content:remove(1)
      end
      this_challenge.content:insert(block)
      needs_challenge = true
    end
  end
  -- Fencepost
  if #this_challenge.content > 1 then
    bookend = pandoc.Div(this_challenge.content, {class = "discussion"})
    challenge_train:insert(callout_block(bookend))
  end
  return(challenge_train)
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
      return pandoc.RawBlock("text", "")
    end
  end

  v,i = el.classes:find("objectives")
  if i ~= nil then
    objectives = el
    if questions ~= nil then
      return overview_card()
    else
      return pandoc.RawBlock("text", "")
    end
  end

  -- Accordion blocks:
  --
  -- Instructor Notes, Solutions, Hints, and Spoilers are all blocks
  -- that are contained in accordion blocks.
  -- For historical reasons, solutions are normally embedded
  -- in challenge blocks, but because of the way pandoc traverses the AST,
  -- we need to process these FIRST and then handle their positioning in the
  -- challenge block phase.
  v,i = el.classes:find("instructor")
  if i ~= nil then
    return(accordion(el, "instructor"))
  end

  v,i = el.classes:find("spoiler")
  if i ~= nil then
    return(accordion(el, "spoiler"))
  end

  v,i = el.classes:find("solution")
  if i ~= nil then
    return(accordion(el, "solution"))
  end

  v,i = el.classes:find("hint")
  if i ~= nil then
    return(accordion(el, "hint"))
  end

  -- Challenge blocks:
  --
  -- Challenge blocks no longer contain solutions, so the solutions (and hints)
  -- now must be extracted into a list of divs.
  v,i = el.classes:find("challenge")
  if i ~= nil then
    return(challenge_block(el))
  end

  -- Tab blocks:
  --
  -- Toggleable Tab blocks.
  v,i = el.classes:find("tab")
  if i ~= nil then
    group_tab = false
    return(tab_block(el))
  end

  -- Group Tab blocks:
  --
  -- Toggleable Group Tab blocks.
  v,i = el.classes:find("group-tab")
  if i ~= nil then
    group_tab = true
    return(tab_block(el))
  end

  -- All other Div tags should have at most level 3 headers
  level_head(el, 3)
  return(callout_block(el))
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
  local tgt;
  if el.target == nil then
    tgt = el.src
  else
    tgt = el.target
  end
  -- Flatten local redirects, e.ge. ../episodes/link.md goes to link.md
  local pat = "^%.%./"
  tgt,_ = tgt:gsub(pat, "")
  tgt,_ = tgt:gsub("^episodes/", "")
  tgt,_ = tgt:gsub("^learners/", "")
  tgt,_ = tgt:gsub("^instructors/", "")
  tgt,_ = tgt:gsub("^profiles/", "")
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
