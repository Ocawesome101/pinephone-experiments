-- framebuffer lib test script

local fb = require("framebuffer")

fb.init(720, 1440)

fb.fill_screen(0xFFFFFF)
fb.fill_area(100, 100, 100, 100, 0xFFFFFF)

fb.flip()
