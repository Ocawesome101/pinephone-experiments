#!/usr/bin/env lua
-- main interface file --

local framebuffer = require("libraries/framebuffer")
local event = require("libraries/event")
local eventlist = require("libraries/event-list")
local transform_event = require("libraries/transformers")
local ui = require("libraries/ui")
local dialog = require("libraries/ui/dialog")
local image = require("libraries/image")

-- TODO: make this configurable
local fb = framebuffer.new("/dev/fb0", 1920, 1080)
local evt = event.new()
  :open("/dev/input/event0", "keyboard")
  :open("/dev/input/event4", "touchpad")

local cursor = image.load_image("resources/cursor.bin")

local function get_event()
  local _from, _type, _code, _value = evt:poll()
  local proc_type, proc_value = transform_event(_type, _code, _value)
  if proc_type then
    return proc_type, proc_value
  end
end

local ui_root = ui.Base {
  framebuffer = fb,
  color = 0x333333,
  y = 0
}

-- protected dofile
local function pdofile(file, ...)
  local ok, err = loadfile(file)
  if not ok then
    local dialog = dialog {
      framebuffer = fb,
      text = "this is a text dialog.",
    }
    ui_root:add_child(dialog)
  else
    return select(2, pcall(ok, ...))
  end
end

local function open_app(file)
  local iface = pdofile(file)
  ui_root:add_child(iface)
end

local cx, cy = 480, 480
local function redraw()
  cx = math.max(1, math.min(cx, fb.w))
  cy = math.max(1, math.min(cy, fb.h))
  ui_root:repaint(1, 1)
  image.draw_image(fb, cursor, cx, cy, 2)
end

local r = true
while true do
  if r then redraw() end
  local e1, e2, e3, e4 = get_event()
  r = not not e1
  if e1 == "mouse_move_x" then cx = cx + e2
  elseif e1 == "mouse_move_y" then cy = cy + e2
  elseif e1 == "click_left" then ui_root:tap(cx, cy)
  end
end
