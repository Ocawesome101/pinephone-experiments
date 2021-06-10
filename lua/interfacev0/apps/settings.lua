-- A settings app.

local ui = require("lib/ui")

local wd, ht = UI_WIDTH, UI_HEIGHT - 88

local window = ui.window.new(1, 1, wd, ht, 0xCCCCCC)

local page = ui.page.new(1, 1, wd, ht, 0xCCCCCC)

window.pages[1] = page

dofile("ui_config.lua")
local config = {
	KEY_FG = KEY_FG or 0,
	KEY_BG = KEY_BG or 0xAAAAAA,
	UI_SCALE = UI_SCALE,
	UI_WIDTH = UI_WIDTH,
	UI_HEIGHT = UI_HEIGHT,
	KEY_WIDTH = KEY_WIDTH or 70,
	KEY_HEIGHT = KEY_HEIGHT or 80,
	KEY_SPACING = KEY_SPACING or 2,
	UI_ICON_SCALE = UI_ICON_SCALE
}

local buttons = {
	{
		field = "UI_SCALE",
		value = UI_SCALE,
		name = "UI Scale"
	},
	{
		field = "UI_ICON_SCALE",
		value = UI_ICON_SCALE,
		name = "Application Icon Scale"
	},
	{
		field = "KEY_HEIGHT",
		value = KEY_HEIGHT or 80,
		name = "Keyboard: Key Height"
	},
	{
		field = "KEY_WIDTH",
		value = KEY_WIDTH or 70,
		name = "Keyboard: Key Width"
	},
	{
		field = "KEY_SPACING",
		value = KEY_SPACING or 2,
		name = "Keyboard: Key Spacing"
	},
	{
		field = "KEY_FG",
		value = KEY_FG or 0,
		name = "Keyboard: Text Color"
	},
	{
		field = "KEY_BG",
		value = KEY_BG or 0xAAAAAA,
		name = "Keyboard: Key Color"
	}
}

for i=1, #buttons, 1 do
	local spage = ui.page.new(1, 1, wd, ht, 0xAAAAAA)
	local spagen = #window.pages + 1
	window.pages[spagen] = spage
	local tbox = ui.textbox.new(1, 88, wd, 17 * UI_SCALE, 0, 0xCCCCCC)
	tbox.text = tostring(buttons[i].value)
	local button = ui.button.new(1, 90 * i - 90, wd, 88,
		string.format("%s = %s", buttons[i].name, buttons[i].value), 0, 0xDDDDDD)
	function tbox:submit()
		buttons[i].value = tonumber(self.text) or buttons[i].value
		config[buttons[i].field] = tonumber(self.text) or config[buttons[i].field]
		window.current = table.remove(window.pagestack)
		window.pages[window.current].draw = true
		button.text = string.format("%s = %s", buttons[i].name, buttons[i].value)
		for k, v in pairs(window.pages[window.current].children) do
			v.draw = true
		end
	end
	spage.children[#spage.children + 1] = tbox
	function button:tap()
		window.pagestack[#window.pagestack + 1] = window.current
		window.current = spagen
		spage.children[1].kb.draw = true
	end
	page.children[#page.children + 1] = button
end

local function save_config()
	local handle = io.open("ui_config.lua", "w")
	for k, v in pairs(config) do
		_G[k] = tonumber(v) or v
		handle:write(string.format("%s = %q\n", k, tonumber(v) or v))
	end
	handle:close()
end

function window:close()
	save_config()
end

return window
