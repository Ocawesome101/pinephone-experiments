#!/usr/bin/env lua
-- main interface file --

local framebuffer = require("libraries/framebuffer")
local event = require("libraries/event")
local eventlist = require("libraries/event-list")
local transform_event = require("libraries/transformers")
local ui = require("libraries/ui")

-- TODO: make this configurable
local fb = framebuffer.new("/dev/fb0", 1920, 1080)
local evt = event.new()
  :open("/dev/input/event0", "keyboard")
  :open("/dev/input/event4", "touchpad")

local function get_event()
end
