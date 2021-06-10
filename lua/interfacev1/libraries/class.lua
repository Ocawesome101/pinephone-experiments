-- classes --

local check = require("libraries/checkArg")

local function inherit(tbl, ...)
  tbl = tbl or {}
  local new = setmetatable({}, {__index = tbl, __call = inherit})
  if new.__init then
    new:__init(...)
  end
  return new
end

local function class(tbl)
  check(1, tbl, "table", "nil")
  return setmetatable(tbl or {}, {__call = inherit})
end

return class
