-- some basic text utilities

local lib = {}

-- text, char width, max total width, text scale
function lib.wrap(text, cw, mw, ts)
	ts = ts or 2
	local ret, n = {}, 0
	local maxlen = mw // (ts * cw)
	local line = ""
	for c in text:gmatch(".") do
		n = n + 1
		if n > maxlen then
			n = 1
			ret[#ret + 1] = line
			line = ""
		end
		line = line .. c
	end
	if #line > 0 then ret[#ret + 1] = line end
	return ret
end

return lib
