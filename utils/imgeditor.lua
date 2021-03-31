-- A proper image editor

local kbd = require("lib/vt_kbd")

local buffer = {}
local x, y = 1, 1
local w, h = tonumber((...)), tonumber((select(2, ...)))
local ccol = {r=0,g=0,b=0}

for i=1, h, 1 do
	buffer[i] = {}
	for j=1, w, 1 do
		buffer[i][j] = {r=0,g=0,b=0}
	end
end

local function redraw()
	for i=1, #buffer, 1 do
		io.write("\27[", tostring(i + 3), ";1H\27[39;49m", tostring(i))
	end

	local rows = {"   ", "   ", "   "}
	for i=1, w, 1 do
		local row = 1
		local n = tostring(i)
		for c in n:gmatch(".") do
			rows[row] = rows[row] .. " " .. c
			row = row + 1
		end
		if row < #rows then
			for i=row, #rows, 1 do
				rows[row] = rows[row] .. " "
			end
		end
	end

	for i=1, #rows, 1 do
		io.write("\27[", tostring(i), ";1H\27[39;49m", rows[i])
	end

	for line=1, #buffer, 1 do
		local ln = buffer[line]
		for col=1, #ln, 1 do
			local ch = ln[col]
			io.write(string.format("\27[%d;%dH\27[48;2;%d;%d;%dm  ",
			 line+3, col*2+3, ch.r, ch.g, ch.b))
		end
	end
	local cc = buffer[y][x]
	io.write(string.format("\27[%d;%dH\27[38;2;%d;%d;%d;48;2;%d;%d;%dm[]",
		y+3, x*2+3, 255 - cc.r, 255 - cc.g, 255 - cc.b, cc.r, cc.g, cc.b))
	
	io.write(string.format("\27[%d;1H\27[39;49mCurrent: \27[48;2;%d;%d;%dm  ",
	  h + 5, ccol.r, ccol.g, ccol.b))
end

io.write("\27[49m\27[2J")
os.execute("stty raw -echo")
while true do
	redraw()
	local key = kbd.get_key()
	if key == "e" then
		io.write("\27[39;49m\27[2J\27[1;1H")
		os.execute("stty sane")
		os.exit()
	elseif key == "c" then
		os.execute("stty sane")
		io.write(string.format("\27[%d;1H\27[39;49mEnter color (0xRRGGBB): ", h + 4))
		local ent = io.read()
		io.write("\27[A\27[2K")
		local rr, rg, rb = ent:match("0x([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])")
		if rr and rg and rb then
			ccol.r = tonumber(rr, 16) or 0
			ccol.g = tonumber(rg, 16) or 0
			ccol.b = tonumber(rb, 16) or 0
		end
		os.execute("stty raw -echo")
	elseif key == "s" then
		os.execute("stty sane")
		io.write(string.format("\27[%d;1H\27[39;49mFilename: ", h + 4))
		local name = io.read()
		io.write("\27[A\27[2K")
		if name == "" or name == "\n" then
			print("not saving")
		else
			local handle, err = io.open(name, "w")
			if not handle then
				print(err)
			else
				for y=1, h, 1 do
					for x=1, w, 1 do
						local ch = buffer[y][x]
						--print(ch.r,ch.g,ch.b)
						handle:write(string.format("%s%s%s\0", string.char(ch.b), string.char(ch.g), string.char(ch.r)))
					end
					handle:write("\n")
				end
				handle:close()
			end
		end
		os.execute("stty raw -echo")
	elseif key == "l" then
		os.execute("stty sane")
    io.write(string.format("\27[%d;1H\27[39;49mFilename: ", h + 4))
    local name = io.read()
    io.write("\27[A\27[2K")
    if name == "" or name == "\n" then
      print("not loading")
    else
      local handle, err = io.open(name, "r")
      if not handle then
        print(err)
      else
				h = 0
				w = 0
				x = 1
				y = 1
				buffer = {}
				local f = {"g","b","r"}
				local i = 0
				for line in handle:lines() do
					buffer[#buffer + 1] = {}
					w = #line / 4
					h = h + 1
					local ch = {}
					i = 0
					for byte in line:gmatch(".") do
						i = i + 1
						if i == 4 then
							buffer[#buffer][#buffer[#buffer] + 1] = ch
							i = 0
							ch = {}
						else
							ch[f[i]] = byte:byte()
						end
					end
				end
				handle:close()
      end
    end
		io.write("\27[39;49m\27[2J")
    os.execute("stty raw -echo")
	elseif key == " " then
		local ch = buffer[y][x]
		ch.r = ccol.r or 0
		ch.g = ccol.g or 0
		ch.b = ccol.b or 0
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
