-- AT command interface for the PinePhone modem

-- Unfortunately we need a C library (lua-periphery) to do proper serial I/O.
-- If possible I'd avoid it.
local open = require("periphery").Serial

local lib = {}
local modem

function lib.init(md)
	modem = assert(open(md, 115200))
	-- Configure the sent message validity period to about 3 days.
	modem:write("AT+CSMP=17,167,0,0\r")
	modem:write("AT+CPMS=\"MT\",,\"MT\"\r")
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

function lib.send_command(cmd, ...)
	chinit()
	if #({...}) > 0 then
	  cmd = string.format(cmd, ...)
	end
	modem:write(cmd .. "\r")
	print(cmd)
	local resp = modem:read(math.huge, 500)
	if resp:match("ERROR") then
		return nil, resp
	end
	print(resp)
	return resp
end

-- SMS is currently implemented in text mode.  This is much simpler than PDU
-- mode.  However, on the PinePhone's modem, there is no way to send Unicode
-- in text mode.
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

-- get indices of available SMS
-- This pattern should match all the fields of a response header
-- In order: Message index, message status, sender, nil, the time of message reception
local sms_header_pattern = "%+CMGL: (%d+),(\"REC U?N?READ\"),\"%+(%d+)\",,\"(.+)\""
function lib.poll_sms()
	-- step 1: List all the available messages
	local messages = lib.send_command("AT+CMGL=\"ALL\"")
	-- step 2: Split the list into lines for ease of parsing
	local lines = {}
	do
		local line = ""
		for c in messages:gmatch(".") do
			if c == "\n" then
				lines[#lines + 1] = line
				line = ""
			elseif c ~= "\r" then
				line = line .. c
			end
		end
		if #line > 0 then lines[#lines + 1] = line end
	end
	-- step 3: Parse the list, line-by-line
	local list = {}
	local index, status, from, time, data = nil, nil, nil, nil, ""
	for i, v in ipairs(lines) do
		if v == "" and lines[i + 1] == "OK" then
			if #data > 0 then
				list[index] = {
					from = from,
					time = time,
					data = data,
					status = status}
			end
			-- Cave Johnson, we're done here.
			return list
		elseif v:match(sms_header_pattern) then
			local I, S, F, T = v:match(sms_header_pattern)
			if index then
				list[index] = {
					from = from,
					time = time,
					data = data,
					status = status}
			end
			index = tonumber(I)
			status = S
			from = "+" .. F
			time = T
			data = ""
		else
			data = data .. v .. "\n"
		end
	end
	return list
end

function lib.delete_sms(index)
	-- Mark the message as read.  I'm not sure if this is necessary.
	lib.send_command("AT+CMGR=%d", index)
	-- Delete the message from the SMS queue.
	lib.send_command("AT+CMGD=%d", index)
	return true
end

return lib
