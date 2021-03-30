-- the UI base

-- some definitions - used for configuration
UI_WIDTH = 720
UI_HEIGHT = 1440
-- the scale of things such as text
UI_SCALE = 2

local ui = require("lib/ui")
local fb = require("lib/framebuffer")
local img = require("lib/fbimg")
local touch = require("lib/touch")
local modem = require("lib/modem")
local text = require("lib/fbfont")

fb.init("/dev/fb0", UI_WIDTH, UI_HEIGHT, true)
touch.init("/dev/input/event1", UI_WIDTH, UI_HEIGHT)
text.load_font("font/font.bin")

local BH = 44
local home = ui.button.new((UI_WIDTH//2) - 60*UI_SCALE, UI_HEIGHT - BH*UI_SCALE,
	120*UI_SCALE, BH*UI_SCALE, nil,
	0x000000, 0x111111, UI_SCALE)
home.image = img.load_image("images/home.bin")
home.xo = (60 * UI_SCALE - ((BH/2) * UI_SCALE))
home.yo = (4 * UI_SCALE)
local back = ui.button.new(1, UI_HEIGHT - BH*UI_SCALE,
	120*UI_SCALE, BH*UI_SCALE, nil,
	0x000000, 0x111111, UI_SCALE)
back.xo = (60 * UI_SCALE - ((BH/2) * UI_SCALE))
back.yo = (4 * UI_SCALE)
back.image = img.load_image("images/back.bin")

function home:tap()
end

local apps = ui.view.new(1, 1, UI_WIDTH, UI_HEIGHT - BH * UI_SCALE, 0x0000AA)

local function draw_base_ui()
	fb.fill_area(1, UI_HEIGHT - 36*UI_SCALE, UI_WIDTH, 36*UI_SCALE, 0x111111)
  home:refresh(1, 1)
	back:refresh(1, 1)
	apps:refresh(1, 1)
end


fb.fill_screen(0)
draw_base_ui()

while true do
	local e, x, y = touch.pull_event()
	if x >= home.x and x <= home.x + home.w
			and y >= home.y and y <= home.y + home.h then
		if e == "touch" then
			home.bg = 0x555555
			home:refresh(1,1)
			home.down = true
		end
	elseif x >= back.x and x <= back.x + back.w
			and y >= back.y and y <= back.y + back.h then
		if e == "touch" then
			back.bg = 0x555555
			back:refresh(1,1)
			back.down = true
		end
	end
	if e == "drop" and home.down then
		home.bg = 0x111111
		home.down = false
		home:refresh(1,1)
		home:tap()
	elseif e == "drop" and back.down then
		back.down = false
		back.bg = 0x111111
		back:refresh(1,1)
		back:tap()
	end
end
