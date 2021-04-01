-- Basic SMS app

local ui = require("lib/ui")
local notifications = require("lib/notifications")

local function send_text(to, text)
	local handle = io.open("/tmp/sent_texts", "a")
		or io.open("/tmp/sent_texts", "r")
	handle:write(string.format("TEXT(+%s,%s)", to, text))
	handle:close()
end

local function load_conversation(num)
	local texts = {}
	local handle = io.open("conversations/"..num..".txt", "r")
	if not handle then return {} end
	local data = handle:read("a")
	handle:close()
	for ft, text in data:gmatch("(.)(%b())\n") do
		texts[#texts + 1] = {
			from = ft == "T" and "me" or tostring(num),
			text = text:sub(2,-2)
		}
	end
	return texts
end

local function save_conversation(texts, num)
	local handle = io.open("conversations/"..num..".txt", "w")
	for i=1, #texts, 1 do
		handle:write(string.format("%s(%s)\n", texts[i].from == "me" and "T" or "F",
			texts[i].text))
	end
	handle:close()
end

local wd, ht = UI_WIDTH, UI_HEIGHT - (44 * UI_SCALE)
local window = ui.window.new(1, 1, wd, ht, 0x444444)

local conversations = {}
do
	local files = {}
	local raw = io.popen("ls conversations", "r")
	for line in raw:lines() do
		files[#files + 1] = line
	end
	raw:close()
	for i=1, #files, 1 do
		local conv = files[i]:gsub("%.txt", "")
		conversations[tonumber(conv)] = load_conversation(conv)
	end
end

local main_page = ui.page.new(1, 1, wd, ht, 0x444444)
local main_view = ui.view.new(1, 1, wd, ht, 0x444444)
main_page.children[1] = main_view
window.pages[1] = main_page
local cn = 1
local function create_conversation(k, v)
	local cpage = ui.page.new(1, 1, wd, ht, 0x444444)
	local view = ui.view.new(1, 1, wd, ht, 0x444444, true)
	local off = 1
	for i=1, #v, 1 do
		local th = math.max(math.ceil((#v[i].text + 10) / wd), 1) * 17 * 2
		local text = ui.label.new(4, off, wd - 8, th,
			v[i].from .. ": " .. v[i].text, 0xFFFFFF)
		text.bg = 0x666666
		view.children[#view.children + 1] = text
		off = off + th + 10
	end
	cpage.children[1] = view
	view.wy = off - ht
	local page = #window.pages + 1
	window.pages[#window.pages + 1] = cpage
	local button = ui.button.new(1, (cn * 89), wd, 88,
		tostring(k), 0xFFFFFF, 0x555555, UI_SCALE)
	main_view.children[#main_view.children + 1] = button
	function button:tap()
		window.pagestack[#window.pagestack + 1] = window.current
		window.current = page
	end
	local tbox = ui.textbox.new(1, 88, wd, 88, 0x000000, 0xDDDDDD)
	function tbox:submit()
		if #self.text > 0 then
			send_text(self.text)
			table.insert(conversations[k], {from = "me", text = self.text})
			local th = math.max(math.ceil((#self.text + 10) / wd), 1) * 17 * 2
    	local text = ui.label.new(4, off, wd - 8, th,
      	"me: " .. self.text, 0xFFFFFF)
    	text.bg = 0x666666
    	view.children[#view.children + 1] = text
    	off = off + th + 20
		end
		self.text = ""
	end
	cpage.children[#cpage.children + 1] = tbox
	cn = cn + 1
end

for k, v in pairs(conversations) do
	create_conversation(k, v)
end

local new = ui.button.new(1, ht - 100, 100, 100, "+", 0x000000, 0x999999, 10)
main_page.children[#main_page.children + 1] = new

local nc_page = ui.page.new(1, 1, wd, ht, 0x444444)
local nc_page_tbox = ui.textbox.new(1, 88, wd, 88, 0x000000, 0xDDDDDD)
nc_page_tbox.kb.page = 2

nc_page.children[#nc_page.children + 1] = nc_page_tbox

function nc_page_tbox:submit()
	if not tonumber(self.text) then return end
	conversations[tonumber(self.text)] = {}
	create_conversation(tonumber(self.text), {})
	window.current = 1
end

local nc_page_n = #window.pages + 1
window.pages[nc_page_n] = nc_page

function new:tap()
	window.pagestack[#window.pagestack + 1] = window.current
	window.current = nc_page_n
end

function window:close()
	for k, v in pairs(conversations) do
		save_conversation(v, k)
	end
end

return window
