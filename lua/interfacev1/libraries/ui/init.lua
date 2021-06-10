------ base UI library ------

local text = require("libraries/text")
local class = require("libraries/class")
local check = require("libraries/checkArg")
local fbtext = require("libraries/framebuffertext")

local ui = {}

---- base object ----

ui.Base = class()

function ui.Base:__init(args)
  self.fb = args.framebuffer or self.framebuffer
  self.w = args.width
  self.h = args.height
  self.x = args.x or 1
  self.y = args.y or 1
  self.color = args.color or 0
  self.children = {}
  return self
end

function ui.Base:tap(x, y)
  for k, v in pairs(self.children) do
    if x > v.x and y > v.y and x < v.x + v.w and y < v.x + v.w then
      v:tap(x - v.x, y - v.y)
      break
    end
  end
  return self
end

-- this function should not be touched
function ui.Base:repaint(x, y, force)
  if self.repaint_needed or force then
    self.fb:fill(x + self.x, y + self.y, self.w, self.h, self.color)
  end
  self.repaint_needed = false
  for k, v in pairs(self.children) do
    v:repaint(x + v.x, y + v.y, force)
  end
  return self
end

---- windows! ----

ui.Window = ui.Base()

function ui.Window:__init(args)
  ui.Base.__init(self, args)
  self.page = 1
  self.pages = type(args.pages) == "table" and args.pages or {}
  return self
end

function ui.Window:add_page(page)
  check(1, page, "table")
  self.pages[#self.pages+1] = page
  return self, #self.pages
end

function ui.Window:switch_page(page)
  self.page = page
  return self
end

function ui.Window:repaint(x, y, force)
  ui.Base.repaint(self, x, y, force)
  if self.pages[self.page] then
    self.pages[self.page]:repaint(self.x + x, self.y + y, force)
  end
end

---- pages ----

ui.Page = ui.Base()

-- pages can pretty much just stay as the base element, since they're
-- effectively windows in windows.

---- labels ----

ui.Label = ui.Base()

function ui.Label:__init(args)
  ui.Base.__init(self, args)
  self.text = {x = 1, y = 1, text = "", scale = 1}
  return self
end

function ui.Label:set_text_pos(x, y)
  self.text.x = x
  self.text.y = y
  return self
end

function ui.Label:set_text_scale(sc)
  self.text.scale = sc
  return self
end

function ui.Label:repaint(x, y, force)
  ui.Base.repaint(self, x, y, force)
  if #self.text.text > 0 then
    -- TODO draw text
  end
  return self
end
