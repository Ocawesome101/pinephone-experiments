-- linux event subsystem lua interface --

local events, codes
do
  local _ = require("libraries/event-list")
  events, codes = _.events. _.codes
end

-- this supports timeout-ed reads :)
local poll = require("posix.poll")
local fileno = require("posix.stdio").fileno

local _evt = {}
