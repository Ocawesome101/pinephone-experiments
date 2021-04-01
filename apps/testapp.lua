local ui = require("lib/ui")

local wd = UI_WIDTH
local ht = UI_HEIGHT - (44 * UI_SCALE)

local win = ui.window.new(1, 1, wd, ht, 0xAAAAAA) 

local page1 = ui.page.new(1, 1, wd, ht, 0x888888)
local page2 = ui.page.new(1, 1, wd, ht, 0x555555)
local label = ui.label.new(1, 1, wd, ht, "Welcome to the UI test app!  This app is intended to be a test of my UI system.", 0, UI_SCALE)
local label2 = ui.label.new(1, 100, wd, ht, "This is a darker page.  Try using the back button on the navigation bar.", 0xFFFFFF, UI_SCALE)
local button = ui.button.new(1, 100, wd, 88, "Tap Me!", 0xFFFFFF, 0, UI_SCALE)

function button:tap()
	win.pagestack[#win.pagestack + 1] = win.current
	win.current = 2
end

win:addpage(page1)
win:addpage(page2)

page1.children[#page1.children + 1] = label
page1.children[#page1.children + 1] = button
page2.children[#page2.children + 1] = label2

return win
