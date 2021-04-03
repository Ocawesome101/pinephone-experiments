-- generate a monochrome image

local fg, bg = ...

local fb = require("lib/framebuffer")

fg = tonumber(fg)
bg = tonumber(bg)

for line in io.lines() do
	local ldat = {}
	for char in line:gmatch(".") do
		if char == "#" then
			ldat[#ldat + 1] = fg
		else
			ldat[#ldat + 1] = bg
		end
	end
	print(fb.pack_line(table.unpack(ldat)))
end
