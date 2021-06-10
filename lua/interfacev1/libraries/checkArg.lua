-- argument checking --

local function check(n, have, ...)
  local want = table.pack(...)
  have = type(have)
  local name = debug.getinfo(2).name
  for i=1, want.n, 1 do
    if have == want[i] then return end
  end
  error(string.format("bad argument #%d to '%s' (%s expected, got %s)",
    n, name, table.concat(want, " or "), have), 3)
end

return check
