-- touchscreen interface library: very basic

-- This is a mapping of event codes to their names and possible codes.
-- TODO: move this list to a separate library and expand it
local events = {
	[0] = {
		name = "SYN_REPORT",
		codes = {},
	},
	[1] = {
		name = "EV_KEY",
		codes = {
			[330] = "BTN_TOUCH"
		},
	},
	[3] = {
		name = "EV_ABS",
		codes = {
			[0] = "ABS_X",
			[1] = "ABS_Y",
			[47] = "ABS_MT_SLOT",
			[53] = "ABS_MT_POSITION_X",
			[54] = "ABS_MT_POSITION_Y"
		}
	},
}

local lib = {}
local touchscreen, w, h

-- tw and th are the screen resolution, in pixels.
-- touchscreen is the **absolute** path in /dev/input to the raw touchscreen
-- device (i.e. /dev/input/event1).
function lib.init(tw, th, touchscreen)
	w, h = tw, th
	touchscreen = assert(io.open(touchscreen, "r"))
	return true
end

-- errors if the library has not properly been initialized.
local function chinit()
	if not touchscreen and w and h then
		error("attempt to use touchscreen without proper initialization")
	end
end

-- For my use, one event consists of 16 bits of garbage (ignored), two unsigned
-- 16-bit integers and a signed 32-bit integer.  There are cases where this
-- isn't 100% correct, but it should cover most uses.
local data_pattern = "I2I2i4"

-- returns event_type, event_code, event_value in that order
local function get_event()
	chinit()
	-- The first 16 bytes are garbage values that only mean things to people
	-- using the C API, one of whom I am certainly not.
	-- This is heavily platform-dependent (i.e. it'll probably be different
	-- on certain architectures).  I'm writing this library for the
	-- PinePhone's touchscreen, so I know exactly what I'm working with.
	-- Also, if the read value is offset at all this will return complete
	-- garbage.
	local _, data = touchscreen:read(16, 8)
	return data_pattern:unpack(data)
end

function lib.pull_event()
end
