-- A proper image editor

local kbd = require("lib/vt_kbd")

local buffer = {}
local x, y = 1, 1
local w, h = tonumber((...)), tonumber((select(2, ...)))
local ccol = {}

for i=1, h, 1 do
	buffer[i] = {}
	for j=1, w, 1 do
		buffer[i][j] = {r=0,g=0,b=0}
	end
end

local function redraw()
	for line=1, #buffer, 1 do
		local ln = buffer[line]
		for col=1, #ln, 1 do
			local ch = ln[col]
			io.write(string.format("\27[%d;%dH\27[48;2;%d;%d;%dm  ",
			  col, line, ch.r, ch.g, ch.b))
		end
	end
	local cc = buffer[y][x]
	io.write(string.format("\27[%d;%dH\27[38;2;%d;%d;%dm[]",
		y, x, 255 - cc.r, 255 - cc.g, 255 - cc.b))
	
	io.write(string.format("\27[%d;1H\27[39;49mCurrent: \27[48;2;%d;%d;%dm  ",
	  h + 2, ccol.r, ccol.g, ccol.b))
end

os.execute("stty raw -echo")
while true do
	redraw()
	local key = kbd.get_key()
	if key == "e" then
		os.execute("stty sane")
		os.exit()
	elseif key == "up" then
		y = math.max(1, y - 1)
	elseif key == "down" then
		y = math.min(h, y + 1)
	elseif key == "left" then
		x = math.max(1, x - 1)
	elseif key == "right" then
		x = math.min(w, x + 1)
	end
end
