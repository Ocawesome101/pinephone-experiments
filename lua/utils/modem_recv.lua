-- Recieve texts.

local md = require("lib/modem")

md.init("/dev/ttyUSB2")

local list = md.poll_sms()

if not list or #list == 0 then
	print("No messages in queue.")
	return
end
for i, v in pairs(list) do
	print("\nMessage index: " .. i)
	print("  Sender: " .. v.from)
	print("  Received at: " .. v.time)
	print("  Message status: " .. v.status)
	print("  Message data: " .. v.data)
	if ({...})[1] == "d" then
		md.delete_sms(i)
	end
end
