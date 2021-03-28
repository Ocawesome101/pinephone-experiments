-- parse touchscreen input (type B protocol)

-- key multitouch protocol events as defined in linux/input-event-codes.h
EV_ABS = 0
ABS_MT_SLOT = 0x2f
ABS_MT_TRACKING_ID = 0x39
SYN_REPORT = 0
SYN_MT_REPORT = 2
ABS_MT_POSITION_X = 0x34
ABS_MT_POSITION_Y = 0x35

-- not ideal: the device name is hardcoded.
local ts = io.open("/dev/input/event1", "r")

local u16, u32 = "I2", "i4"
local function pollevent()
	-- as far as i can work out, the input_event struct defined in the kernel
	-- is exactly 8 bytes: 2 unsigned 16-bit ints (type,code) and a 32-bit
	-- value
	local _, etype, ecode, evalue = ts:read(16, 2, 2, 4)
	return u16:unpack(etype), u16:unpack(ecode), u32:unpack(evalue)
end

local function polltouchscreen()
  local et, ec, ev = pollevent()
  print(et, ec, ev)
  local x, y, p
  if et == EV_ABS then
	  if ec == 0 or ec == 53 then
		  print("Got ABS_MT_POSITION_X", ev)
	  elseif ec == 1 or ec == 54 then
		  print("Got ABS_MT_POSITION_Y", ev)
	  elseif ec == 24 then
		  print("Got pressure event:", ev)
	  end
  end
end

local slots = {}
local slot = nil
local track_id = nil
local last
while true do
	polltouchscreen()
end
