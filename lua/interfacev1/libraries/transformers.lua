-- event transformers. --
-- TODO: this library will break under certain circumstances when the events of
-- multiple different devices of the same types are passed through it, since it
-- keeps some internal state.  perhaps remove internal state-keeping?

local events, codes
do
  local _ = require("libraries/event-list")
  events, codes = _.events, _.codes
end
local keycodes = require("libraries/keycodes")

-- key name: { unshifted, shifted }
-- if no shifted variant, unshifted will be used
local key_aliases = {
  minus = {"-", "_"},
  equal = {"=", "+"},
  leftbrace = {"[", "{"},
  rightbrace = {"]", "}"},
  semicolon = {";", ":"},
  apostrophe = {"'", "\""},
  grave = {"`", "~"},
  backslash = {"\\", "|"},
  comma = {",", "<"},
  dot = {".", ">"},
  slash = {"/", "?"},
  kpasterisk = {"*"},
  space = {" "},
  kp7 = {"7"},
  kp8 = {"8"},
  kp9 = {"9"},
  kpminus = {"-"},
  kp4 = {"4"},
  kp5 = {"5"},
  kp6 = {"6"},
  kpplus = {"+"},
  kp1 = {"1"},
  kp2 = {"2"},
  kp3 = {"3"},
  kp0 = {"0"},
  kpdot = {"."},
  kpenter = {"enter"},
  kpslash = {"/"},
  kpequal = {"="},
  kpcomma = {","},
  ["1"] = {"1", "!"},
  ["2"] = {"2", "@"},
  ["3"] = {"3", "#"},
  ["4"] = {"4", "$"},
  ["5"] = {"5", "%"},
  ["6"] = {"6", "^"},
  ["7"] = {"7", "&"},
  ["8"] = {"8", "*"},
  ["9"] = {"9", "("},
  ["0"] = {"0", ")"},
}

local transformers = {}

local keystates = {
  [0] = "release",
  [1] = "press",
  [2] = "repeat"
}

local ktstate = {
  shift = false,
  capslock = false
}

-- key transformer for key state and capslock - basically, sanity
transformers[events.EV_KEY] = function(code, value)
  local key_name = keycodes[code]
  local key_state = keystates[value]
  if key_name == "leftshift" or key_name == "rightshift" then
    ktstate.shift = not (key_state == "release")
  elseif keyname == "capslock" then
    ktstate.capslock = not (key_state == "release")
  end
  local shift = (ktstate.shift and not ktstate.capslock) or
                (ktstate.capslock and not ktstate.shift)
  
  key_name = key_aliases[key_name] or key_name

  -- this works because Lua strings have their __index metamethod set to the
  -- string API - so, even if key_name is a string, key_name[1] just indexes
  -- string[1] or nil.
  key_name = key_name[shift and 2 or 1] or key_name[1] or key_name
  return "key", key_name, key_state
end

local mtstate = {
  lastx = 0,
  lasty = 0
}

-- mouse event transformer
transformers[events.EV_ABS] = function(code, value)
  -- TODO: make this support multitouch and whatnot
  -- TODO: until then, on multitouch trackpads this will behave weirdly
  -- with more than one finger under some circumstances
  if code == codes.EV_ABS.ABS_X then
    if mtstate.lastx == 0 then mtstate.lastx = value return nil end
    local diff = mtstate.lastx - value
    mtstate.lastx = value
    if diff > -30 and diff < 30 then
      return "mouse_move_x", -diff
    end
  elseif code == codes.EV_ABS.ABS_Y then
    if mtstate.lasty == 0 then mtstate.lasty = value return nil end
    local diff = mtstate.lasty - value
    mtstate.lasty = value
    if diff > -30 and diff < 30 then
      return "mouse_move_y", -diff
    end
  elseif code == codes.EV_KEY.BTN_LEFT then
    return "click_left", "left"
  elseif code == codes.EV_KEY.BTN_RIGHT then
    return "click_right", "right"
  elseif code == codes.EV_KEY.BTN_MIDDLE then
    return "click_middle", "middle"
  elseif code == codes.EV_KEY.BTN_TOUCH then -- one finger
    return value == 1 and "fingers_down" or "fingers_up", 1
  elseif code == codes.EV_KEY.BTN_TOOL_DOUBLETAP then -- two fingers
    return value == 1 and "fingers_down" or "fingers_up", 2
  elseif code == codes.EV_KEY.BTN_TOOL_TRIPLETAP then -- three fingers
    return value == 1 and "fingers_down" or "fingers_up", 3
  elseif code == codes.EV_KEY.BTN_TOOL_QUADTAP then -- four fingers
    return value == 1 and "fingers_down" or "fingers_up", 4
  end
  return nil
end

local function transform(etype, code, value)
  if transformers[etype] then
    return transformers[etype](code, value)
  end
  return etype, code, value
end

return transform
