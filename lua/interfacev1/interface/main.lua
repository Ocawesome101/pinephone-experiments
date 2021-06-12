#!/usr/bin/env lua
-- main interface file --

local framebuffer = require("libraries/framebuffer")
local event = require("libraries/event")
local eventlist = require("libraries/event-list")
local transform_event = require("libraries/transformers")
local ui = require("libraries/ui")
local dialog = require("libraries/ui/dialog")
local image = require("libraries/image")

dofile("ui.cfg")

local fb = framebuffer.new(FRAMEBUFFER_FILE or "/dev/fb0",
  SCREEN_WIDTH or 1920, SCREEN_HEIGHT or 1080)
local evt = event.new()
if INPUT_KEYBOARD then evt:open(INPUT_KEYBOARD, "keyboard") end
if INPUT_TOUCHPAD then evt:open(INPUT_TOUCHPAD, "touchpad") end
if INPUT_TOUCHSCREEN then evt:open(INPUT_TOUCHSCREEN, "touchscreen") end

local cursor = io.open("resources/cursor.txt")
cursor = cursor:read("a")

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
      text = err,
    }
    ui_root:add_child(dialog)
    return
  else
    return select(2, pcall(ok, ...))
  end
end

local function open_app(file)
  local iface = pdofile(file)
  if iface then ui_root:add_child(iface) end
end

local cx, cy = 480, 480
local ocx, ocy = 480, 480
local cdb = {}

local function refresh()
  -- overwrite old cursor
  for i=ocy, ocy+32, 1 do
    if cdb[i - ocy + 1] then
      fb:__set_raw(ocx, i, cdb[i - ocy + 1])
    end
  end
  ocx, ocy = cx, cy

  -- repaint UI
  ui_root:repaint(0, 0)

  -- copy screen data at cursor pos to buffer
  for i=cy, cy+32, 1 do
    fb:__set_raw(cx, i, "")
    local ok, err = fb.__handle:read(32*4)
    cdb[i-cy+1] = ok or cdb[i-cy+1]
  end

  -- write cursor data to framebuffer
  local line = ""
  local o = 0
  local n = 0
  for c in cursor:gmatch(".") do
    if c == " " then o = o + 1
    elseif c == "\n" then fb:__set_raw(cx + o, cy + n, line); o = 0; line = ""; n = n + 1
    elseif c == "#" then line = line .. "\xEE\xEE\xEE\0"
    elseif c == "." then line = line .. "\0\0\0\0" end
  end
end

local function redraw()
  cx = math.max(1, math.min(cx, fb.w))
  cy = math.max(1, math.min(cy, fb.h))
  refresh()
end

open_app("tesT")

redraw()

local r = true
while true do
  if r then redraw() end
  local e1, e2, e3, e4 = get_event()
  r = not not e1
  if e1 == "mouse_move_x" then cx = cx + e2
  elseif e1 == "mouse_move_y" then cy = cy + e2
  elseif e1 == "click_left" then ui_root:tap(cx, cy)
  elseif e1 == "key" then ui_root:key(e2, e3) end
end
