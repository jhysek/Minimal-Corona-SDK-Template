--------------------------------------------------------------------------------
local class = require "lib.middleclass"
local widget = require "widget"
local Color  = require "lib.Color"
--------------------------------------------------------------------------------

local BlockBtn = class("BlockBtn")

local colors = {
  main    = Color.convertHexToRGB(appconfig.main_color),
  green   = { 0.2, 0.8, 0.2, 1 },
  gray    = { 0.5, 0.5, 0.5, 0.6 },
  blue    = { 0.2, 0.2, 0.8, 1 },
  red     = Color.convertHexToRGB("#9F0637"),
  darkred = Color.convertHexToRGB("#7F0017"),
  default = { 0.2, 0.8, 0.2, 1 }
}

function BlockBtn:initialize(parent, y, text, color, onPress, width, x)
  self.displayObject = widget.newButton({
    label = text,
    x = x or (_W / 2),
    y = y,
    width = width or (_AW - 60),
    height = _AH / 14,
    shape = 'rect',
    fillColor = { default = colors[color], over = colors[color] },
    labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
    font = "OpenSans-Light",
    fontSize = 15,
    onRelease = onPress
  })
  parent:insert(self.displayObject)
  return self.displayObject
end

return BlockBtn
