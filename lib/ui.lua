-- User interface library.

local fb = require("lib/framebuffer")
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
		self.pages[self.current]:scroll(x-self.x, y-self.y, xd, yd)
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
	self.parent = parent
	fb.fill_area(self.x+x, self.y+y, self.w, self.h, self.bg)
	for k, v in pairs(self.children) do
		v:refresh(self.x+x, self.y=y)
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

-- Views: Can be scrollable and any size
local view = {}
ui.view = {}

function view.new(x, y, w, h, bg, sc)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,sc=sc,sx=0,sy=0,children={}},
		{__index = view})
end

function view:refresh(x, y)
	self.parent = parent
	fb.fill_area(self.x+x,self.y+y, self.w, self.h, self.bg)
	for k, v in pairs(self.children) do
		-- TODO: better scroll checks?
		if v.y - self.sy > 0 and v.x - self.sx > 0 then
			v:refresh(self.x+x, self.y+y)
		end
	end
end

function view:tap(x, y)
	for k, v in pairs(self.children) do
		if x >= self.x and x <= self.x+self.w
				and y >= self.y and y <= self.y+self.h then
			v:tap()
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

local label = {}
ui.label = label

local textbox = {}
ui.textbox = textbox

return ui
