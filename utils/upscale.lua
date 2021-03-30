-- double the size of an "image" source

for line in io.lines() do
	local ln = ""
	for c in line:gmatch(".") do
		ln = ln .. c .. c
	end
	io.write(ln, "\n", ln, "\n")
end
