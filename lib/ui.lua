-- User interface library.

local fb = require("lib/framebuffer")
local img = require("lib/fbimg")
local text = require("lib/fbfont")
local ui = {}

-- Highest-level concept: Windows
local window = {}
ui.window = window

function window.new(x, y, w, h, bg)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,pages={},pagestack={},current=1},
		{__index = window})
end

function window:refresh()
	fb.fill_area(self.x, self.y, self.w, self.h, self.bg)
	if self.pages[self.current] then
		self.pages[self.current]:refresh(self.x,self.y)
	end
end

function window:tap(x, y)
	if self.pages[self.current] then
		self.pages[self.current]:tap(x-self.x, y-self.y)
	end
end

-- startX, startY, xDist, yDist, in that order
function window:scroll(x, y, xd, yd)
	if self.pages[self.current] then
		self.pages[self.current]:scroll(x-self.x, y-self.y, -xd, -yd)
	end
end

function window:addpage(page)
	self.pages[#self.pages+1] = page
	page.n = #self.pages
end

function window:close()
	-- Does nothing by default
end

-- Pages
local page = {}
ui.page = page

function page.new(x, y, w, h, bg)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,children={}},
		{__index = page})
end

function page:refresh(x,y)
	fb.fill_area(self.x+x, self.y+y, self.w, self.h, self.bg)
	for k, v in pairs(self.children) do
		v:refresh(self.x+x, self.y+y)
	end
end

function page:tap(x, y)
	for k, v in pairs(self.children) do
		if x >= v.x and x <= v.x+v.w and
				y >= v.y and y <= v.y+v.h then
			v:tap(x - self.x, y - self.y)
		end
	end
end

function page:scroll(x, y, xd, yd)
	for k, v in pairs(self.children) do
		if x >= v.x and x <= v.x+v.w and
				y >= v.y and y <= v.y+v.h and v.sc then
			v:scroll(xd, yd)
		end
	end
end

-- Views: Can be scrollable and any size
local view = {}
ui.view = view

function view.new(x, y, w, h, bg, sc)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,sc=sc,sx=0,sy=0,children={}},
		{__index = view})
end

function view:refresh(x, y)
	--print("S", self.sx, self.sy)
	fb.fill_area(self.x+x,self.y+y, self.w, self.h, self.bg)
	for k, v in pairs(self.children) do
		-- TODO: better scroll checks?
		--if v.y - self.sy > 0 and v.x - self.sx > 0 then
			v:refresh(self.x+x, self.y+y-self.sy)
		--end
	end
end

function view:tap(x, y)
	for k, v in pairs(self.children) do
		if x >= self.x+v.x and x <= self.x+v.x+v.w
				and y >= self.y+v.y and y <= self.y+v.h+v.h then
			v:tap(x-self.x+v.x, y-self.y+v.y)
		end
	end
end

function view:scroll(xd, yd)
	if self.sc then
		self.sx = self.sx + xd
		self.sy = self.sy + yd
	end
end

-- Buttons, labels, textboxes
local button = {}
ui.button = button

function button.new(x, y, w, h, text, fg, bg, ts)
	ts = ts or 2
	return setmetatable({x=x,y=y,w=w,h=h,text=text,fg=fg,bg=bg,ts=ts},
		{__index = button})
end

function button:refresh(x, y)
	fb.fill_area(x+self.x, y+self.y, self.w, self.h, self.bg)
	local xo, yo = self.xo or 0, self.yo or 0
	local ixo, iyo = self.ixo or 0, self.iyo or 0
	if self.text then
	  text.write_at(x+self.x+xo, y+self.y+yo, self.text, self.fg, self.ts)
	end
	if self.image then
		img.draw_image(self.image, x+self.x+ixo, y+self.y+iyo, self.is or self.ts)
	end
end

function button:tap()
end

function button:scroll()
end

local label = {}
ui.label = label

function label.new(x, y, w, h, text, fg, ts)
	ts = ts or 2
	return setmetatable({x=x,y=y,w=w,h=h,text=text,fg=fg,ts=ts},
		{__index = label})
end

function label:refresh(x, y)
	-- text wrapping
	--print("L", x, y)
	-- TODO possibly move this to lib/fbfont or perhaps a text utils lib
	local maxlen = self.w // (self.ts*10) -- assume char spacing of (2*scale)px
	local lines, n = {}, 0
	local line = ""
	for c in self.text:gmatch(".") do
		n = n + 1
		if n > maxlen then
			n = 1
			lines[#lines + 1] = line
			line = ""
		end
		line = line .. c
	end
	if #line > 0 then lines[#lines + 1] = line end
	for i=1, #lines, 1 do
		--print(lines[i])
		text.write_at(self.x+x, self.y+y+((17*self.ts)*i-(17*self.ts)), lines[i], self.fg, self.ts)
	end
end

function label:tap()
end

function label:scroll()
end

local textbox = {}
ui.textbox = textbox
-- TODO: textbox element

return ui
