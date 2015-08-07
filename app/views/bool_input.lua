--------------------------------------------------------------------------------
local widget = require "widget"

local class = require "lib.middleclass"
local GenericInput = require "app.views.generic_input"
--------------------------------------------------------------------------------

local BoolInput = class("BoolInput", GenericInput)

function BoolInput:drawInput()
  local valueText = "NE"
  local imgname   = 'switch_off.png'
  local x = 16

  if self.input_value then
    imgname = 'switch_on.png'
    valueText = "ANO"
    x = - 17
  end

  local img = display.newImage(self.group, "assets/" .. imgname)
  img:scale(0.14, 0.13)

  local text = display.newText
  {
    parent = self.group,
    fontSize = 13,
    font = system.nativeFont,
    x = x,
    y = 0,
    text = valueText,
    align = "right",
    width = self.options.width
  }

  if self.input_value then
    text:setFillColor(1,1,1,0.7)
  else
    text:setFillColor(0,0,0,0.7)
  end

end

function BoolInput:setFocus()
  self.input_value = not self.input_value
  self:redraw()
end

return BoolInput
