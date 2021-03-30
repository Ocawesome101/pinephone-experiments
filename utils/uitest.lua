-- a simple test UI

local ui = require("lib/ui")
local fb = require("lib/framebuffer")
local tch = require("lib/touch")
local text = require("lib/fbfont")

fb.init("/dev/fb0", 1440, 720, true)
tch.init("/dev/input/event1", 1440, 720)
text.load_font("font/font.bin")

local win = ui.window.new(1, 1, 1440, 720, 0)
local page = ui.page.new(1, 1, 1440, 720, 0x00AAFF)
local view = ui.view.new(1, 1, 1440, 720, 0x00FFAA, true)
local label = ui.label.new(1, 1, 720, 720, ("This is a very large, very extremely overly square label.  This text should wrap."):rep(10), 0x0)

view.children[1] = label
page.children[1] = view
win.pages[1] = page

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
