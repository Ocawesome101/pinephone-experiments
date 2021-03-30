-- touchscreen interface library: very basic

-- Max gap before swipes are considered scrolling.
local MAXGAP = 10

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
-- ts is the **absolute** path in /dev/input to the raw touchscreen
-- device (i.e. /dev/input/event1).
function lib.init(ts, tw, th)
	w, h = tw, th
	touchscreen = assert(io.open(ts, "r"))
	return true
end

-- errors if the library has not properly been initialized.
local function chinit()
	if not (touchscreen and w and h) then
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

-- Get a tap or scroll.
local cx, cy = 0, 0
function lib.pull_event()
	local x, y = cx, cy
	while true do
		-- Retrieve an event.
		local et, ec, ev = get_event()
		--print(et, ec, ev)
		-- If the event is recognized, process it.
		if events[et] then
			local ed = events[et]
			local cd = ed.codes[ec]
			--print(ed.name, cd)
			if ed.name == "SYN_REPORT" then
				-- Ignore this.  It seems to be unnecessary.
				-- If I find a use for it later I'll add
				-- handling here.
			elseif ed.name == "EV_ABS" then
				if cd == "ABS_MT_POSITION_X" or c == "ABS_X" then
					x = ev
					if cx == 0 then cx = x end
				elseif cd == "ABS_MT_POSITION_Y" or c == "ABS_Y" then
					y = ev
					if cy == 0 then cy = y end
				end
			elseif ed.name == "EV_KEY" then
				if cd == "BTN_TOUCH" and x ~= 0 and y ~= 0
						and ev == 0 then
					-- This means the user removed their finger
					-- and there isn't a "ghost tap" at [0,0]
					-- so we can register a tap and return [x,y].
					cx, cy = 0, 0
					return "drop", x, y
				elseif cd == "BTN_TOUCH" and x ~= 0 and y ~= 0
						and ev == 1 then
					-- The user put their finger down.
					return "touch", x, y
				end
			end
			if (cx ~= 0 and cy ~= 0) and (x ~= 0 and y ~= 0) and
				(cx - x > MAXGAP or cx - x < -MAXGAP or
					cy - y > MAXGAP or cy - y < -MAXGAP) then
				local dx, dy = -(cx - x), -(cy - y)
				cx, cy = x, y
				return "scroll", dx, dy
			end
		end
	end
end

return lib
