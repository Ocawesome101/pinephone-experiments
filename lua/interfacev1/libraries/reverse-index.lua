-- reverse indexing --

local check = require("libraries/checkArg")

local function revidx(tab)
  check(1, tab, "table")

  local tomerge = {}

  for k, v in pairs(tab) do
    tomerge[v] = k
  end

  for k, v in pairs(tomerge) do
    tab[k] = v
  end

  -- some may expect this
  return tab
end

return revidx
