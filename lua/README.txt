My goal is to use as few C libraries as possible.

The modem library depends on `lua-periphery` because I don't think it's possible, or at least simple, for standard Lua to read from serial interfaces properly.  The modem notification listener requires `luasocket` for sleeping a certain amount of time.
