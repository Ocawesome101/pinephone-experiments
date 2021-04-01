-- User interface library.

local fb = require("lib/framebuffer")
local img = require("lib/fbimg")
local text = require("lib/fbfont")
local tu = require("lib/text")
local ui = {}

-- Highest-level concept: Windows
local window = {draw = true}
ui.window = window

function window.new(x, y, w, h, bg)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,pages={},pagestack={},current=1},
		{__index = window})
end

function window:refresh()
	if self.draw then
		fb.fill_area(self.x, self.y, self.w, self.h, self.bg)
		self.draw = false
	end
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
local page = {draw = true}
ui.page = page

function page.new(x, y, w, h, bg)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,children={}},
		{__index = page})
end

function page:refresh(x,y)
	if self.draw then
	  fb.fill_area(self.x+x, self.y+y, self.w, self.h, self.bg)
		self.draw = false
	end
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
			self.draw = true
			for k, v in pairs(self.children) do v.draw = true end
		end
	end
end

-- Views: Can be scrollable and any size
local view = {draw = true}
ui.view = view

function view.new(x, y, w, h, bg, sc)
	return setmetatable({x=x,y=y,w=w,h=h,bg=bg,sc=sc,sx=0,sy=0,children={}},
		{__index = view})
end

function view:refresh(x, y)
	if self.draw then
		fb.fill_area(self.x+x,self.y+y, self.w, self.h, self.bg)
		self.draw = false
	end
	for k, v in pairs(self.children) do
		-- TODO: better scroll checks?
		if v.y - self.sy >= 0 and v.y <= self.y + self.h then
			v:refresh(self.x+x, self.y+y-self.sy)
		end
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
		self.draw = true
		for k,v in pairs(self.children) do
			v.draw = true
		end
	end
end

-- Buttons, labels, textboxes
local button = {draw = true}
ui.button = button

function button.new(x, y, w, h, text, fg, bg, ts)
	ts = ts or 2
	return setmetatable({x=x,y=y,w=w,h=h,text=text,fg=fg,bg=bg,ts=ts},
		{__index = button})
end

function button:refresh(x, y)
	if self.draw then
		fb.fill_area(x+self.x, y+self.y, self.w, self.h, self.bg)
		local xo, yo = self.xo or 0, self.yo or 0
		local ixo, iyo = self.ixo or 0, self.iyo or 0
		if self.text then
		  text.write_at(x+self.x+xo, y+self.y+yo, self.text, self.fg, self.ts)
		end
		if self.image then
			img.draw_image(self.image, x+self.x+ixo, y+self.y+iyo, self.is or self.ts)
		end
		self.draw = false
	end
end

function button:tap()
end

function button:scroll()
end

local label = {draw = true}
ui.label = label

function label.new(x, y, w, h, text, fg, ts)
	ts = ts or 2
	return setmetatable({x=x,y=y,w=w,h=h,text=text,fg=fg,ts=ts},
		{__index = label})
end

function label:refresh(x, y)
	if self.draw then
		if self.bg then
			fb.fill_area(x+self.x, y+self.y, self.w, self.h, self.bg)
		end
		-- text wrapping
		local lines = tu.wrap(self.text, 10, self.w, self.ts)
		for i=1, #lines, 1 do
			text.write_at(self.x+x, self.y+y+((17*self.ts)*i-(17*self.ts)), lines[i], self.fg, self.ts)
		end
		self.draw = false
	end
end

function label:tap()
end

function label:scroll()
end

-- Textbox: textbox with a keyboard attached.
-- TODO: make the keyboard optional.
local textbox = {}
ui.textbox = textbox

-- Some constants.
local KEY_HEIGHT = 80
local KEY_WIDTH = 68
local KEY_SPACING = 4
local KEY_FG = 0x000000
local KEY_BG = 0xAAAAAA
local KB_HEIGHT = (KEY_HEIGHT * 4) + (KEY_SPACING * 2) + KEY_SPACING 

-- internal keyboard object
local _kb = {pages={}, draw = true}

function _kb:refresh(x, y)
	local sd = self.draw
	fb.fill_area(self.x, self.y, self.w, self.h, self.bg)
	local buttons = self.pages[self.page or 1]
	for i=1, #buttons, 1 do
		buttons[i].draw = true
		buttons[i]:refresh(x, self.y)--x+self.x, y+self.y)
	end
end

function _kb:tap(x, y)
	local buttons = self.pages[self.page or 1]
	y = y - self.y
	for i=1, #buttons, 1 do
		local b = buttons[i]
		if x >= b.x and x <= b.x+b.w and
				y >= b.y and y <= b.y+b.h then
			b:tap(self)
			return
		end
	end
end

function _kb:key()
end

-- TODO: localization support
-- for now the keyboard is QWERTY only
do
	local pages = {
		{
			-- B: Blank space
			-- H: half-key offset
			-- S: Shift
			-- N: Next page
			-- P: Previous page
			-- D: Backspace
			-- R: Return/enter
			-- ' ': Space bar (5 buttons wide)
			"qwertyuiop",
			"Hasdfghjkl",
			"SzxcvbnmD",
			"N, .R"
		},
		{
			"1234567890",
			"-/:;()$&@\"",
			"NH.H,H?H!H'D",
			"PB BR"
		},
		{
			"[]{}#%^*+=",
			"_H\\H|H~H<H>H`",
			"PH.H,H?H!H'D",
			"NB BR"
		}
	}

	for i, l in ipairs(pages) do
		local p = {}
		_kb.pages[i] = p
		local x, y = 1, 1
		for _, ln in ipairs(l) do
			x = 1
			for c in ln:gmatch(".") do
				if c == "H" then
					x = x + ((KEY_WIDTH + KEY_SPACING) // 2)
				elseif c == "B" then
					x = x + KEY_WIDTH + KEY_SPACING
				elseif c == "S" then
					local bt = ui.button.new(x+KEY_SPACING//2, y,
						KEY_WIDTH, KEY_HEIGHT, "shf",
						KEY_FG, KEY_BG, UI_SCALE)
					function bt:tap(k)
						k.shifted = not k.shifted
						if k.shifted then
							self.text = "SHF"
						else
							self.text = "shf"
						end
					end
					p[#p + 1] = bt
					x = x + KEY_WIDTH + KEY_SPACING
				elseif c == "N" then
					local bt = ui.button.new(x+KEY_SPACING//2, y,
						KEY_WIDTH, KEY_HEIGHT, "Nxt",
						KEY_FG, KEY_BG, UI_SCALE)
          function bt:tap(k)
						if k.page == #k.pages then
							k.page = 1
						else
							k.page = k.page + 1
						end
          end
          p[#p + 1] = bt
          x = x + KEY_WIDTH + KEY_SPACING
				elseif c == "P" then
					local bt = ui.button.new(x+KEY_SPACING//2, y, 
						KEY_WIDTH, KEY_HEIGHT, "Prv",
						KEY_FG, KEY_BG, UI_SCALE)
					function bt:tap(k)
						if k.page == 1 then
							k.page = #k.pages
						else
							k.page = k.page - 1
						end
					end
					p[#p + 1] = bt
					x = x + KEY_WIDTH + KEY_SPACING
				elseif c == "D" then
					local bt = ui.button.new(x+KEY_SPACING//2, y, 
						((KEY_WIDTH*1.5)//1), KEY_HEIGHT, "Bksp",
						KEY_FG, KEY_BG, UI_SCALE)
					function bt:tap(k)
						k:key("backspace")
					end
					p[#p + 1] = bt
					x = x + KEY_WIDTH + KEY_SPACING
				elseif c == "R" then
					local bt = ui.button.new(x+KEY_SPACING//2, y, 
						KEY_WIDTH*2+KEY_SPACING, KEY_HEIGHT, "Return",
						KEY_FG, KEY_BG, UI_SCALE)
					function bt:tap(k)
						k:key("return")
					end
					p[#p + 1] = bt
					x = x + KEY_WIDTH + KEY_SPACING
				elseif c == " " then
					local bt = ui.button.new(x, y,
						(KEY_WIDTH+KEY_SPACING)*5, KEY_HEIGHT, "",
						KEY_FG, KEY_BG, UI_SCALE)
					function bt:tap(k)
						k:key(" ")
					end
					p[#p+1] = bt
					x = x + (KEY_WIDTH+KEY_SPACING)*5
				else
					local bt = ui.button.new(x+KEY_SPACING//2, y, 
						KEY_WIDTH, KEY_HEIGHT, c,
						KEY_FG, KEY_BG, UI_SCALE)
					function bt:tap(k)
						k:key(k.shifted and c:upper() or c)
					end
					p[#p + 1] = bt
					x = x + KEY_WIDTH + KEY_SPACING
				end
			end
			y = y + KEY_HEIGHT + (KEY_SPACING // 2)
		end
	end
end

-- TODO: y coordinate currently hardcoded
function textbox.new(x, y, w, h, fg, bg)
	local new
	local UI_HEIGHT = UI_HEIGHT or 1440
	local UI_WIDTH = UI_WIDTH or 720
	new = setmetatable({
		kb = setmetatable({
			x = 1,
			y = UI_HEIGHT - KB_HEIGHT - y,
			w = UI_WIDTH,
			h = KB_HEIGHT,
			fg = 0,
			bg = 0,
			page = 1,
			key = function(_, k)
				new:key(k)
			end
		}, {
			__index = _kb
		}),
		text = "",
		shifted = "A",
		fg = fg,
		bg = bg,
		x = x,
		y = ((UI_HEIGHT - KB_HEIGHT) - h) - y,
		w = w,
		h = KB_HEIGHT + h
	}, {__index = textbox})
	return new
end

function textbox:refresh(x, y)
	local UI_SCALE = UI_SCALE or 2
	local lines = tu.wrap(self.text.."|", 10, self.w - 8, UI_SCALE)
	fb.fill_area(x + self.x, y + self.y, self.w, self.h, self.bg)
	for i = #lines - (self.h // (17*UI_SCALE)), #lines, 1 do
		text.write_at(x + self.x + 4, y + self.y + ((17*i*UI_SCALE) - (17*UI_SCALE)) + 4, lines[i] or "", self.fg, UI_SCALE)
	end
	self.kb:refresh(x + self.x, y + self.y + self.h)
end

function textbox:key(k)
	if k == "backspace" then
		if #self.text >= 1 then
			self.text = self.text:sub(1, -2)
		end
	elseif k == "return" then
		if self.submit then
			self:submit()
		end
	else
		self.text = self.text .. k
	end
end

function textbox:tap(x, y)
	self.kb:tap(x, y)
end

return ui
