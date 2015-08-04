--------------------------------------------------------------------------------
local class = require "lib.middleclass"
--------------------------------------------------------------------------------

local GenericInput = class("GenericInput")

function GenericInput:initialize(parent, left, top, width, options)
  self.options = options or {}
  self.parent  = parent
  self.width   = width
  self.height  = self.options.height or 30
  self.top     = top
  self.left    = left
  self.input_value   = self.options.value
  self.group   = display.newGroup()

  self:redraw()
end

function GenericInput:redraw()
  if self.group then
    self.group:removeSelf()
  end
  self.group = display.newGroup()
  self.group.anchorX = 0
  self.group.anchorY = 0
  self.group.x = self.left
  self.group.y = self.top

  self:drawInput()

  self.parent:insert(self.group)
end

function GenericInput:setErrorMode()
  self.errorMode = true
  self:redraw()
end

function GenericInput:clear()
  self.input_value = nil
  self.valueLabel = nil
  self:redraw()
end

function GenericInput:setValue(value)
  self.input_value = value
  self:redraw()
end

function GenericInput:value()
  return self.input_value
end

function GenericInput:required()
  return self.options.required
end

function GenericInput:setFocus()
end

return GenericInput
