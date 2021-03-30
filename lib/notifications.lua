-- basic notification library, basically just a FIFO queue.

local lib = {}

-- write a notification
function lib.send(notif)
	local file = io.open("/tmp/lua_notifs", "a")
	file:seek("end")
	file:write(notif, "\n")
	file:close()
end

-- get all notifications
function lib.recv(clear)
	local file = io.open("/tmp/lua_notifs", "r")
	file:seek("set")
	local data = file:read("a")
	file:close()
	if clear then
		io.open("/tmp/lua_notifs", "w"):close()
	end
	return data
end

return lib
