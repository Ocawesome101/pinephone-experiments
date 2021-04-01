local ui = require("lib/ui")

local wd = UI_WIDTH
local ht = UI_HEIGHT - (44 * UI_SCALE)

local win = ui.window.new(1, 1, wd, ht, 0xAAAAAA) 

local page = ui.page.new(1, 1, wd, ht, 0x888888)
local label = ui.label.new(1, 1, wd, ht, "Welcome to the UI test app!  This app is intended to be a test of my UI system.", 0, UI_SCALE)

win:addpage(page)

page.children[#page.children + 1] = label

return win
