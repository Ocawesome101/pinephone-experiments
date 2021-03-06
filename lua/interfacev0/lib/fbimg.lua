-- Framebuffer image utility
-- Images are pretty much just raw framebuffer data
-- split into lines

local fb = require("lib/framebuffer")

local lib = {}

function lib.load_image(file)
	local handle = assert(io.open(file, "r"))
	local img = {}
	for line in handle:lines("l") do
		img[#img + 1] = line
	end
	return img
end

function lib.draw_image(img, x, y, s)
	local o = 0
	for i=1, #img, 1 do
		local line = img[i]
		if s then
			line = ""
			for c in img[i]:gmatch("....") do
				line = line .. c:rep(s)
			end
			for n=1, s, 1 do
				fb.write_at(x, y + o - 1, line)
				o = o + 1
			end
		else
			fb.write_at(x, y + o - 1, line)
			o = o + 1
		end
	end
end
--[[
function lib.draw_image(img, x, y, s)
	local o = 0
	for i=1, #img, 1 do
		local line = img[i]
		if s then
			local p = 0
			for seg in line:gmatch("....") do
				local col = (seg:byte(1)*256*256)+(seg:byte(2)*256)+(seg:byte(3))
				fb.fill_area(x + p, y + o - 1, s, s)
				p = p + s
			end
			o = o + s
		else
			local p = 0
			for seg in line:gmatch("....") do
				local col = (seg:byte(1)*256*256)+(seg:byte(2)*256)+(seg:byte(3))
				fb.set_pixel(x + p, y + o - 1, col)
				p = p + 1
			end
			o = o + 1
		end
	end
end]]

return lib
