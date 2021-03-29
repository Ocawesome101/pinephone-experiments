local n = 0
for line in io.lines() do
  if n == 0 or n == 13 then
		io.stderr:write("begin character: ", line, "\n")
    io.write(line)
    n = 1
  else
    local byte = 0
    local N = 0
    for c in line:gmatch(".") do
      if c == "#" then
        byte = byte | (2^N)
      end
      N = N + 1
    end
    n = n + 1
    io.write(string.char(byte))
  end
end
