-- framebuffer library test --

local fb = require("libraries.framebuffer").new("/dev/fb0", 1920, 1080)

fb:fill("a")
