--------------------------------------------------------------------------------
local composer                = require "composer"
local class                   = require "lib.middleclass"
local native                  = require "native"
local GenericInput            = require "app.views.generic_input"
--------------------------------------------------------------------------------

local TableSelectInput = class("TableSelectInput", GenericInput)

function TableSelectInput:showOptions()
  composer.showOverlay("app.views.table_select_input_options", {
    effect = "slideLeft",
    time = 200,
    isModal = true,
    params = {
      back_scene = "app.add_wine",
      options  = self.options.collection(),
      val_attr = self.options.valueAttribute,
      opt_attr = self.options.optionAttribute,
      selected = self:value(),
      title    = self.options.label,
      onChanged = function(value, label)
        self.input_value = value
        self.valueLabel = label
        self:redraw()
      end
    }
  })
end

function TableSelectInput:drawInput()
  -- background --------------------------------------------
  if self.errorMode then
    local bg = display.newRect(self.group, 0, self.height - 1, self.width, 1)
    bg.anchorX = 0
    bg:setStrokeColor(1, 0, 0)
  end

  -- draw value / placeholder ------------------------------
  local value = self:value()

  if self:value() or self.placeholder then

    local valueText = display.newText
    {
      parent = self.group,
      x = 5,
      y = self.options.height / 2,
      align = "left",
      fontSize = 13,
      font = native.systemFont,
      width = self.width - 40,
      text = self.valueLabel or self:value() or self.placeholder
    }

    if self:value() then
      valueText:setFillColor(0,0,0,1)
    else
      valueText:setFillColor(0,0,0,0.5)
    end
    valueText.anchorX = 0
  end

  -- draw arrow --------------------------------------------
  local arrow = display.newImage(self.group, "assets/right.png")
  arrow.x = self.width - 5
  arrow.y = self.options.height / 2
  arrow:scale(0.6, 0.6)
  arrow.alpha = 0.5

  self.parent:addEventListener("tap", function()
    self:showOptions()
  end)
end

return TableSelectInput
