-- test

local handle = io.open("/dev/fb0", "w")
local rnd = ""
for i=1, 1440*720, 1 do
  handle:write(string.char(math.random(0, 255)))
end
--handle:write(rnd)
handle:close()