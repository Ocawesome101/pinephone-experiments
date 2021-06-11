-- read from /tmp/ui_out and write that to the framebuffer
-- should make the UI more responsive

dofile("ui.cfg")

local fb = require("libraries/framebuffer").new(FRAMEBUFFER_FILE or "/dev/fb0",
  SCREEN_WIDTH, SCREEN_HEIGHT)

-- initialize the buffer
local handle = io.open("/tmp/ui_out", "w")
handle:write(string.rep("\0\0\0\0", SCREEN_WIDTH * SCREEN_HEIGHT))
handle:close()

handle = io.open("/tmp/ui_out", "r")

-- main loop
while true do
  handle:seek("set", 0)
  fb.__handle:seek("set", 0)
  repeat
    local h = handle:read(0xFFFF*4)
    if h then fb.__handle:write(h); fb.__handle:flush() end
  until not h
end
