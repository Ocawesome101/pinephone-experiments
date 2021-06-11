------ base UI library ------

local text = require("libraries/text")
local class = require("libraries/class")
local check = require("libraries/checkArg")
local fbtext = require("libraries/framebuffertext")

local ui = {}

fbtext.load_font("resources/font.bin")

-- used in calculating sizes and positions relative to parent objects. --
local function calc_pos(self, n)
  local w = self.parent and self.parent.w or self.fb.w
  return math.floor((n / 100) * w)
end

---- base object ----

ui.Base = class()

function ui.Base:__init(args)
  self.repaint_needed = true
  self.fb = args.framebuffer or self.fb or {}
  self.w = args.width or self.fb.w
  self.h = args.height or self.fb.h
  self.x = args.x or 1
  self.y = args.y or 1
  self.color = args.color or 0
  self.children = {}
  return self
end

function ui.Base:tap(x, y)
  for k, v in pairs(self.children) do
    if x > calc_pos(self, v.x) and y > calc_pos(self, v.y)
        and x < calc_pos(self, v.x + v.w)
        and y < calc_pos(self, v.x + v.w) then
      v:tap(x - v.x, y - v.y)
      break
    end
  end
  return self
end

function ui.Base:key(key, state)
  for k, v in pairs(self.children) do
    v:key(key, state)
  end
  return self
end

function ui.Base:add_child(chl)
  chl.parent = self
  self.children[#self.children+1] = chl
  return self
end

-- this function should not be touched
function ui.Base:repaint(x, y, force)
  if not self.fb.fill then self.fb = self.parent.fb or {} end
  if self.repaint_needed or force then
    self.fb:fill(
      calc_pos(self, self.x) + x,
      calc_pos(self, self.y) + x,
      calc_pos(self, self.w),
      calc_pos(self, self.h), self.color)
  end
  self.repaint_needed = false
  for k, v in pairs(self.children) do
    v:repaint(x + v.x, y + v.y, force)
  end
  return self
end

---- windows! ----

ui.Window = ui.Base({})

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
    self.pages[self.page]:repaint(
      calc_pos(self, self.x) + x,
      calc_pos(self, self.y) + y, force)
  end
end

---- pages ----

ui.Page = ui.Base({})

-- pages can pretty much just stay as the base element, since they're
-- effectively windows in windows.

---- labels ----

ui.Label = ui.Base({})

function ui.Label:__init(args)
  ui.Base.__init(self, args)
  self.text = {x = 1, y = 1, text = "", scale = 2, parent = self}
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
  local orepn = self.repaint_needed
  ui.Base.repaint(self, x, y, force)
  if orepn or force then
    if #self.text.text > 0 then
      fbtext.write_at(self.fb,
        y + calc_pos(self, self.x) + calc_pos(self.text, self.text.x),
        x + calc_pos(self, self.y) + calc_pos(self.text, self.text.y),
        self.text.text, self.text.color or 0,
        self.text.scale)
    end
  end
  self.repaint_needed = false
  return self
end

return ui
