-- AT command interface for the PinePhone modem

-- Unfortunately we need a C library (lua-periphery) to do proper serial I/O.
-- If possible I'd avoid it.
local open = require("periphery").Serial

local lib = {}
local modem

function lib.init(md)
	modem = assert(open(md, 115200))
	-- Configure the sent message validity period to about 3 days.  Also
	-- configures to send as unicode (hexadecimal).
	modem:write("AT+CSMP=17,167,0,0\r")
	print(modem:read(1024, 500))
end

local function chinit()
	if not (modem) then
		error("attempt to use uninitialized modem")
	end
end

function lib.read_message()
	chinit()
	return modem:read(64, 500)
end

function lib.send_command(cmd)
	chinit()
	modem:write(cmd .. "\r")
	print(cmd)
	local resp = modem:read(1024, 500)
	print(resp)
	return resp
end

-- SMS is currently implemented in text mode.  This is much simpler than PDU
-- mode.
-- 'num' must be a full phone number with the '+' omitted, ex. +13459871234
-- becomes 13459871234.
function lib.send_sms(num, message_text)
	-- Ensure that the modem is in SMS text mode
	lib.send_command("AT+CMGF=1")
	local cmd = string.format("AT+CMGS=\"+%d\"", num)
	-- Send the command.
	lib.send_command(cmd)
	-- Send the message.
	lib.send_command(message_text)
	print(message_text)
	-- Actually send the message.
	local data = lib.send_command("\26")
	-- Read the serial number.
	local sn = tonumber(data:match("%d+"))
	-- Return the serial number.
	return sn
end

return lib
