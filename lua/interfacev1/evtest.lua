-- event library test --

local evt = require("libraries/event").new()
local list = require("libraries/event-list")

evt:open("/dev/input/event0", "keyboard")
evt:open("/dev/input/event4", "touchpad")

while true do
  local from, etype, code, value = evt:poll()
  if etype then
    print(from, list.events[etype] or etype,
    (list.codes[list.events[etype] or etype] or {})[code] or code, value)
  end
end
