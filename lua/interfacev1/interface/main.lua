#!/usr/bin/env lua
-- main interface file --

local framebuffer = require("libraries/framebuffer")
local ui = require("libraries/ui")

-- TODO: make this configurable
local fb = framebuffer.new("/dev/fb0", 1920, 1080)


