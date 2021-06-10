-- Framebuffer image utility
-- Images are pretty much just raw framebuffer data
-- split into lines

local lib = {}

function lib.load_image(file, w)
	local handle = assert(io.open(file, "r"))
	local img = {}
  if w then 
    for line in function() return handle:read(w) end do
      img[#img + 1] = line
    end
  else
    for line in handle:lines("l") do
      img[#img + 1] = line
    end
  end
	return img
end

function lib.draw_image(fb, img, x, y, s)
	local o = 0
	for i=1, #img, 1 do
		local line = img[i]
		if s then
			line = ""
			for c in img[i]:gmatch("....") do
				line = line .. c:rep(s)
			end
			for n=1, s, 1 do
				fb:__set_raw(x, y + o - 1, line)
				o = o + 1
			end
		else
			fb:__set_raw(x, y + o - 1, line)
			o = o + 1
		end
	end
end

return lib
