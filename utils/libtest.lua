-- Test the libraries included in this repository.

local fb = require("lib/framebuffer")
local fn = require("lib/fbfont")
local ts = require("lib/touch")

-- change these if not running on the PinePhone
fb.init("/dev/fb0", 1440, 720, true)
ts.init("/dev/input/event1", 1440, 720)
fn.load_font("font/font.bin")

fb.fill_screen(0x00AAFF)
fb.fill_area(100, 100, 200, 200, 0xFFFF00)
fb.fill_area(100, 500, 200, 200, 0xFF0000)
fn.write_at(100, 100, "CLICK ME", 0x0, 2)
fn.write_at(100, 500, "EXIT!", 0, 3)
fn.write_at(1, 1, "large.", 0, 10)

while true do
	local x, y = ts.pull_event()
	print("User tapped at", x, y)
	if x > 100 and x < 300 and y > 100 and y < 300 then
		print("user clicked button yey")
	elseif x > 100 and x < 300 and y > 500 and y < 700 then
		fb.fill_screen(0)
		os.exit()
	end
end
