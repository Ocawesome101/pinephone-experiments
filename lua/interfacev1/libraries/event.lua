-- lua interface for the linux event subsystem.  depends on luaposix.  i've done
-- my best to comment this library reasonably well, so others can see what i'm
-- doing and in some cases why i'm doing it.

local events, codes
do
  local _ = require("libraries/event-list")
  events, codes = _.events, _.codes
end

-- for non-blocking reads
local poll = require("posix.poll").poll
local fileno = require("posix.stdio").fileno

local check = require("libraries/checkArg")

local _evt = {}

-- this is the event data that matters for the API.
-- two 16-bit unsigned integers and one 32-bit signed integer.
local evt_pattern = "<I2I2i4"

function _evt:read_event(i)
  check(1, i, "number")
  
  -- the first 16 bytes of an event contain timestamps and whatnot, which would
  -- require further parsing;  so, at least for now, i'm skipping them.  open an
  -- issue if you need support for them.
  self.files[i]:read(16)

  -- these are the 8 bytes that matter
  local data = self.files[i]:read(8)

  return evt_pattern:unpack(data)
end

-- returns:
--  * the device's ID (assigned as the second argument to :open()
--  * the event type
--  * the event code
--  * the event's data value
function _evt:poll()
  -- first, poll files for available data
  local available = poll(self.fds, 10)
  
  -- poll() returns 0 if there is no available data
  if available == 0 then return end

  for i, v in pairs(self.fds) do
    -- is there data available?
    if v.revents.IN then
      -- 1.  read the event data.
      local etype, ecode, evalue = self:read_event(i)

      -- 2.  if the event is in the list, then act on it.
      if events[etype] then
        local codes = codes[ecode]
        -- 3.  only return one event at a time.
        return self.ids[i], etype, ecode, evalue
      else
        return nil, "unrecognized event " .. etype
      end
    end
  end
end

-- add the file 'file' with ID 'id'
function _evt:open(file, id)
  check(1, file, "string")
  check(2, id, "string")
  
  -- open the file
  local handle = assert(io.open(file, "r"))
  
  -- get the file descriptor associated with the file handle
  local no = fileno(handle)

  -- register the ID, handle, and file descriptor
  self.ids[no] = id
  self.files[no] = handle
  -- POLLIN:  "Data other than high-priority data may be read without blocking"
  self.fds[no] = { events = { IN = true } }
  return self
end

return {
  new = function()
    return setmetatable(
      { files = {}, fds = {}, ids = {} },
      { __index = _evt })
  end
}
