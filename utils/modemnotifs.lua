-- Modem notifications

local modem = require("lib/modem")
local fb = require("lib/framebuffer")
local tx = require("lib/fbfont")
local tu = require("lib/text")

fb.init("/dev/fb0", 720, 1440)

modem.init("/dev/ttyUSB2")

local seen = {}
while true do
	local messages = modem.poll_sms()
	for k, v in pairs(messages) do
		notifications.send(string.format(
			"TEXT(+%s,%s,%s)", v.from, v.time, v.text
		))
		-- draw the notification.
		local text = "+"..v.from..": " .. v.text
		local lines = tu.wrap(text, 10, 700, 2)
		fb.fill_area(1, 1, 720, #lines * 17 * 2 + 20, 0xFFFFFF)
		for i=1, #lines, 1 do
			tx.write_at(10, 10 + i * 17 * 2 - 17 * 2, 0, 2)
		end
		-- some sort of delay.  very hacky.
		for i=1, 1000, 1 do
			io.open("/tmp/unimportant", "w"):close()
		end
		modem.delete_sms(k)
	end
	do
		local handle = io.open("/tmp/sent_texts", "r")
		if handle then
			local data = handle:read("a")
			handle:close()
			for n, text in data:gmatch("TEXT%(%+(%d+),(.+)%)\n") do
				modem.send_sms(tonumber(n), text)
			end
		end
	end
end
