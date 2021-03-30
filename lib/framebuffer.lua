-- Library for drawing things on the Linux framebuffer

local framebuffer, w, h, o, offsetcoords
o = 0

local lib = {}

-- pack a color for use with the framebuffer
local function pack_color(r, g, b)
	--print(r, g, b)
	return string.char(b)..string.char(g)..string.char(r).."\0"
end

-- unpack a 24-bit RGB hex color into [r, g, b]
local function unpack_color(hex)
	return
	  (hex >> 16) & 0xFF,
	  (hex >> 8) & 0xFF,
	  (hex & 0xFF)
end

local function chinit()
	if not (framebuffer and w and h) then
		error("attempt to use uninitialized framebuffer")
	end
end

function lib.init(fb, mw, mh, of)
	framebuffer = assert(io.open(fb, "w"))
	w, h = mw, mh
	o = (16 - w or 0) % 16
	offsetcoords = not not of
end

-- Pack a series of colors into a line.  May visibly speed up drawing complex
-- imagery if used properly.
function lib.pack_line(...)
	local args = {...}
	local ret = ""
	for i=1, #args, 1 do
		ret = string.format("%s%s", ret, pack_color(unpack_color(args[i])))
	end
	return ret
end

-- Current position in the framebuffer file.  Used to avoid unnecessary seeking.
local fbcp = 0
-- Write the raw string (text) at (x, y) in the framebuffer.
-- This operates on the raw framebuffer *file*, so it isn't as fast as direct
-- memory access.  This is a trade-off I have chosen to make for convenience
-- so I don't have to write any C.  It also is a bit safer.
-- Unlike most of the other functions, this function expects a rawly encoded
-- string.
function lib.write_at(x, y, text)
	chinit()
	-- the user may expect these to begin at [1,1]
	if offsetcoords then
	  y = y - 1
	end
	local byte = (x * 4) + (y * (w + o) * 4) - 4
	--local byte = ((x * 4) + (y * w * 4)) - 4
	if fbcp ~= byte then
		fbcp = framebuffer:seek("set", byte)
	end
	framebuffer:write(text)
	framebuffer:flush()
	return true
end

-- Quickly clear the screen.
function lib.fill_screen(color)
	chinit()
	local fbc = pack_color(unpack_color(color))
	local towrite = string.rep(fbc, (w + o) * h)
	lib.write_at(1, 1, towrite)
	return true
end

function lib.set_pixel(x, y, color)
	chinit()
	local fbc = pack_color(unpack_color(color))
	lib.write_at(x, y, fbc)
	return true
end

function lib.fill_area(x, y, fw, fh, color)
	chinit()
	local fbc = pack_color(unpack_color(color))
	if x + fw > w then
		fw = fw - ((x + fw) - w)
	end
	if fw <= 0 then return true end
	local towrite = string.rep(fbc, fw)
	for i=y, y+fh-1, 1 do
		lib.write_at(x, i, towrite)
	end
	return true
end

return lib
