-- better framebuffer library --

local check = require("libraries/checkArg")

local _fb = {}

local function compute_xy(x, y, w, h)
  return (x * 4) + (y * w * 4) - 5
end

local function pack_color(num)
  local r, g, b = (num & 0xFF0000) >> 16, (num & 0xFF00) >> 8, num & 0xFF
  return string.char(b)..string.char(g)..string.char(r).."\0"
end

function _fb:__set_raw(x, y, data)
  self.__handle:seek("set", compute_xy(x, y, self.w, self.h))
  self.__handle:write(data)
  self.__handle:flush()
  return true
end

function _fb:fill(x, y, w, h, c)
  check(1, x, "number")
  check(2, y, "number")
  check(3, w, "number")
  check(4, h, "number")
  check(5, c, "number")
  if w == self.w and x == 1 then -- this performs better, i think
    local str = pack_color(c):rep(w*h)
    self:__set_raw(x, y, str)
  else
    local str = pack_color(c):rep(w)
    for i=1, h, 1 do
      self:__set_raw(x, y+i-1, str)
    end
  end
  return true
end

function _fb:set(x, y, c)
  check(1, x, "number")
  check(2, y, "number")
  check(3, c, "number")
  self:__set_raw(x, y, pack_color(c))
  return true
end

return { new = function(file, width, height)
  local handle = assert(io.open(file, "r+"))
  return setmetatable({__handle = handle, w = width, h = height},
    {__index = _fb})
end }
