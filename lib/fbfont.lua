-- Basic font support for my framebuffer driver

local fb = require("lib/framebuffer")

local lib = {}

local font = {}

-- The font format:
--   - One character is 13 bytes; the font is 8x12
--   - The first byte of each character is the ASCII byte to which it maps
--   - Each byte after that represents one row of the character,
--       each bit one pixel
function lib.load_font(file)
  local handle = assert(io.open(file, "r"))
  repeat
    local char, data = handle:read(1, 12)
    if char and data then font[char] = data end
  until not char
end

-- draw character 'char' at [x, y] with color 'color' and scale multiplier
-- 'scale' (must be integer)
function lib.draw_glyph(x, y, char, color, scale)
  if not font[char] then return end
  for i=1, 12, 1 do
    local n = font[char]:sub(i,i):byte()
    for b=0, 7, 1 do
      local draw = n & (2^b) ~= 0
      if draw then
        fb.fill_area(x + (b * scale), y + (i - 1) * scale, scale, scale, color)
      end
    end
  end
  return true
end

-- like draw_glyph, but takes a multi-character string
function lib.write_at(x, y, str, color, scale)
	local jump = 10 * scale
	for i=1, #str, 1 do
		local dx = x + (jump * i)
		lib.draw_glyph(dx, y, str:sub(i,i), color, scale)
	end
end

return lib
