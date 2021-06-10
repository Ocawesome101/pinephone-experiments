-- a simple test UI

local ui = require("lib/ui")
local fb = require("lib/framebuffer")
local tch = require("lib/touch")
local text = require("lib/fbfont")

fb.init("/dev/fb0", 720, 1440, true)
tch.init("/dev/input/event1", 720, 1440)
text.load_font("font/font.bin")

local win = ui.window.new(1, 1, 720, 1440, 0)
local page = ui.page.new(1, 1, 720, 1440, 0x00AAFF)

local tbox = ui.textbox.new(1, 720, 72, 0, 0xFFFFFF)
tbox.text = "TEST"

page.children[1] = tbox
win.pages[1] = page

print(tbox.x, tbox.y, tbox.w, tbox.h)

win:refresh()

local sxs, sys = 0, 0
while true do
	local t, x, y = tch.pull_event()
	print(t, x, y)
	if t == "touch" then
		sxs, sys = x, y
	elseif t == "scroll" then
		win:scroll(sxs, sys, x, y)
	elseif t == "drop" then
		sxs, sys = 0, 0
		win:tap(x, y)
		win:refresh()
	end
end
