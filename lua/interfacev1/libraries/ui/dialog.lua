-- dialogs! --

local ui = require("libraries/ui")

local function create(args)
  local base = ui.Label {
    fb = args.framebuffer,
    x = 5,
    y = 50,
    width = 90,
    height = 15,
    color = args.color or 0xFFFFFF
  }

  base:set_text_pos(10, 10):set_text_scale(2).text.text = args.text
  base.text.color = 0

  local button = ui.Label {
    fb = args.framebuffer,
    width = 80,
    height = 30
  }

  button:set_text_pos(10, 60):set_text_scale(3).text.text = args.text or "DIALOG!!"

  return base
end

return create
