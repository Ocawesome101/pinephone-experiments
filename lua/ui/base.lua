-- the UI base

-- some definitions - used for configuration
UI_WIDTH = 720
UI_HEIGHT = 1440
-- the scale of things such as text
UI_SCALE = 2
-- hardcoded list of apps, their icons, and their script paths.
-- will be dynamic later.
-- Icons are 32*32 for now, since I don't have a big enough terminal
-- to comfortably go bigger and the image editor doesn't support scrolling.
UI_APPS = {
	{name = "Test",
		icon = "images/testapp.bin",
	  script = "apps/testapp.lua"},
	{name = "Texts",
		icon = "images/texts.bin",
		script = "apps/texts.lua"},
	{name = "Settings",
		icon = "images/settings.bin",
		script = "apps/settings.lua"}
}
UI_ICON_SCALE = UI_SCALE * 2

-- a real configuration file :O
dofile("ui_config.lua")

local ui = require("lib/ui")
local fb = require("lib/framebuffer")
local img = require("lib/fbimg")
local touch = require("lib/touch")
local text = require("lib/fbfont")

fb.init("/dev/fb0", UI_WIDTH, UI_HEIGHT, true)
touch.init("/dev/input/event1", UI_WIDTH, UI_HEIGHT)
text.load_font("font/font.bin")

local BH = 44
local home = ui.button.new((UI_WIDTH//2) - 60*UI_SCALE, UI_HEIGHT - BH*UI_SCALE,
	120*UI_SCALE, BH*UI_SCALE, nil,
	0x000000, 0x111111, UI_SCALE)
home.image = img.load_image("images/home.bin")
home.ixo = (60 * UI_SCALE - ((BH/2) * UI_SCALE))
home.iyo = (4 * UI_SCALE)
local back = ui.button.new(1, UI_HEIGHT - BH*UI_SCALE,
	120*UI_SCALE, BH*UI_SCALE, nil,
	0x000000, 0x111111, UI_SCALE)
back.ixo = (60 * UI_SCALE - ((BH/2) * UI_SCALE))
back.iyo = (4 * UI_SCALE)
back.image = img.load_image("images/back.bin")

local apps = ui.view.new(1, 1, UI_WIDTH, UI_HEIGHT - BH * UI_SCALE, 0x00AAFF)
local app

function home:tap()
	if app and app.close then
		app:close()
		apps.draw = true
		for k, v in pairs(apps.children) do
			v.draw = true
		end
	end
	app = nil
end

function back:tap()
	if app then
		local last = app.pagestack[#app.pagestack]
		if last then
			app.pages[app.current].draw = true
      for k, v in pairs(app.pages[app.current].children) do
        v.draw = true
        if v.children then
          for K, V in pairs(v.children) do
            V.draw = true
          end
        end
      end
			app.pagestack[#app.pagestack] = nil
			app.current = last
			app.pages[app.current].draw = true
			for k, v in pairs(app.pages[app.current].children) do
				v.draw = true
				if v.children then
					for K, V in pairs(v.children) do
						V.draw = true
					end
				end
			end
		end
	end
end


local xof = 0
local yof = 0
for i=1, #UI_APPS, 1 do
	local btn = ui.button.new(
		48 + xof, 48 + yof,
		32 * UI_ICON_SCALE, 32 * UI_ICON_SCALE + 16 * UI_SCALE,
		UI_APPS[i].name,
		0xFFFFFF, 0x00AAFF,
		UI_SCALE)
	function btn:tap()
		app = loadfile(UI_APPS[i].script, nil, _G)()
	end

	btn.yo = (32 * UI_ICON_SCALE + 2 * UI_SCALE)
	btn.xo = (btn.w // 2) - ((10 * UI_SCALE * #btn.text) // 2)
	btn.image = assert(img.load_image(UI_APPS[i].icon))
	btn.is = UI_ICON_SCALE

	xof = xof + 48 * UI_ICON_SCALE

	apps.children[#apps.children + 1] = btn
end

local function draw_base_ui()
	fb.fill_area(1, UI_HEIGHT - 36*UI_SCALE, UI_WIDTH, 36*UI_SCALE, 0x111111)
	home.draw = true
  home:refresh(1, 1)
	back.draw = true
	back:refresh(1, 1)
	if app and app.refresh then
		app:refresh()
	else
		apps:refresh(1, 1)
	end
end

fb.fill_screen(0)
draw_base_ui()

while true do
	local e, x, y = touch.pull_event()
	if x >= home.x and x <= home.x + home.w
			and y >= home.y and y <= home.y + home.h then
		if e == "touch" then
			home.bg = 0x555555
			home.draw = true
			home:refresh(1,1)
			home.down = true
		end
	elseif x >= back.x and x <= back.x + back.w
			and y >= back.y and y <= back.y + back.h then
		if e == "touch" then
			back.bg = 0x555555
			back.draw = true
			back:refresh(1,1)
			back.down = true
		end
	end
	if e == "drop" and home.down then
		home.bg = 0x111111
		home.down = false
		home:refresh(1,1)
		home:tap()
		draw_base_ui()
	elseif e == "drop" and back.down then
		back.down = false
		back.bg = 0x111111
		back:refresh(1,1)
		back:tap()
		draw_base_ui()
	elseif e == "drop" then
		if y <= UI_HEIGHT - BH * UI_SCALE then
			if app and app.tap then
				app:tap(x,y)
			else
				apps:tap(x, y)
			end
		end
		draw_base_ui()
	end
end
