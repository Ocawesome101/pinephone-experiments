-- Send AT commands directly to the modem

local md = require("lib/modem")

md.init("/dev/ttyUSB2")

print(md.send_command(...))
