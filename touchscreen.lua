-- parse touchscreen input (type B protocol)

-- key multitouch protocol commands as defined in linux/input-event-codes.h
local codes = {
	EV_SYN = 0,
	EV_ABS = 3,
	ABS_MT_SLOT = 0x2f,
	ABS_MT_TRACKING_ID = 0x39,
	SYN_REPORT = 0,
	SYN_MT_REPORT = 2,
	ABS_MT_POSITION_X = 0x34,
	ABS_MT_POSITION_Y = 0x35,
}

-- not ideal: the device name is hardcoded.
local handle = io.open("/dev/input/event1", "r")

-- full event sequence for one event, as far as i can make out:
--

while true do
end
