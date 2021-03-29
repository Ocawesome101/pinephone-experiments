for line in io.lines() do
  local n
  for c in line:gmatch(".") do
    if c == "#" then
      n = true
      io.write("\27[47m  \27[40m")
    elseif c == " " then
      n = true
      io.write("\27[41m  \27[40m")
    else
      --io.write(c,c)
    end
  end
  if n then io.write("\n") end
end
