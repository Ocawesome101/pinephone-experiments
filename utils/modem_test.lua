-- Test the modem library.

local modem = require("lib/modem")

modem.init("/dev/ttyUSB2")

modem.send_sms(tonumber((...)), select(2, ...) or "This is a test SMS.")
