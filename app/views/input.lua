--------------------------------------------------------------------------------
local class = require "lib.middleclass"
local native = require "native"
require "lib.scaled_text_field"
--------------------------------------------------------------------------------

local Input = class("Input")

local function presence(text)
  if text and string.len(text) > 0 then
    return text
  else
    return nil
  end
end

function Input:initialize(parent, left, top, width, options)
  self.options = options or {}
  self.group = display.newGroup()
  self.group.anchorX = 0
  self.group.anchorY = 0
  self.group.x = left
  self.group.y = top
  self.group.width = width
  self.screenGroup = options.screenGroup

  local border = display.newRect(- width / 2, -16, width, 32)
  border.anchorX = 0; border.anchorY = 0
  if options.inputFillColor then
    Color.setFillHexColor(border, options.inputFillColor)
  else
    border:setFillColor(0, 0, 0, 0.07)
  end
  border.strokeWidth = 0
  border:addEventListener("tap", function()
    self:setFocus()
    return true
  end)
  self.border = border
  self.group:insert(border)

  if options.underlined then
    local line = display.newRect(self.group, -width / 2, 16, width, 1)
    line.anchorX = 0
    line:setFillColor(0,0,0,0.4)
  end

  local platformName = system.getInfo( "platformName" )
  if ( platformName == "iPhone OS" ) then
    self.nativeInput = native.newScaledTextField(0, 0, width - 10, 13)
  else
    self.nativeInput = native.newScaledTextField(-6, 3, width - 10, 13)
  end
  if options.input_type then
    self.nativeInput.inputType = options.input_type
  end

  self.nativeInput.text = self.options.value
  self.nativeInput.hasBackground = false
  self.nativeInput:addEventListener( "userInput", function(e) self:keybordInputHandler(e) end)
  self.nativeInput.isVisible = false
  self.nativeInput.isSecure = options.isSecure or false

  self.placeholder = self.options.placeholder
  self.valueText = display.newText({
    parent = self.group,
    x = 2,
    y = 2,
    width = width - 10 - (options.value_padding_right or 0),
    height = 22,
    font = "Helvetica Neue",
    fontSize = self.options.value_font_size or 13,
    align = self.options.value_align or "left",
    text = presence(self.options.value) or presence(self.placeholder) or ""
  })
  if presence(self.options.value) then
    self.valueText:setFillColor(0, 0, 0, 0.8)
  else
    self.valueText:setFillColor(0, 0, 0, 0.3)
  end
  self.isVisible = true

  self.group:insert(self.nativeInput)

  if self.options.placeholder then
    self.nativeInput.placeholder = self.options.placeholder
  end

  parent:insert(self.group)
  return self
end

function Input:hideKeyboard()
  print("INPUT:hideKeyboard()")
  self.nativeInput.isVisible = false
  if self.options.isSecure then
    self.valueText.text = "••••••"
  else
    self.valueText.text = self.nativeInput.text
  end

  self.valueText.isVisible = true

  if self.valueText.text == "" then
    self.valueText:setFillColor(0, 0, 0, 0.3)
    self.valueText.text = self.placeholder
  else
    self.valueText:setFillColor(0, 0, 0, 0.8)
  end

  if self.errorMode then
    if self.valueText.text == "" then
      self.border:setStrokeColor(1, 0, 0, 1)
      self.border:setFillColor(1, 0, 0, 0.02)
      if self.label then
        self.label:setFillColor(1,0,0)
      end
    else
      self.border:setStrokeColor(0, 0, 0, 0.2)
      self.border:setFillColor(0, 0, 0, 0.02)
      if self.label then
        self.label:setFillColor(0,0,0)
      end
    end
  end

  if native.keyboardFocus == self.nativeInput then
    native.setKeyboardFocus(nil)
    native.keyboardFocus = nil
  end

  if self.onFinishEditing then
    self.onFinishEditing()
  end
end

function Input:setFocus()
  if not self.options.readOnly then
    native.keyboardFocus = self.nativeInput
    native.setKeyboardFocus(self.nativeInput)
    self.nativeInput.isVisible = true
    self.valueText.isVisible = false

    local diff = 0
    if self.screenGroup and self.screenGroup.originalY then
      diff = self.screenGroup.originalY - self.screenGroup.y
    end

    local xAbsPos, yAbsPos = self.nativeInput:localToContent(0,0)

    self.belowScreenHalf = diff + yAbsPos - _H / 2
    if self.belowScreenHalf + 10 > 0 and self.screenGroup then
      if self.options.gridView then
        self.options.gridView:scrollRelative(math.min(- self.belowScreenHalf, 0))
      end

      if self.onStartEditing then
        self.onStartEditing()
      end
    end
  end
end

function Input:keybordInputHandler(event)
  -- zacatek editace ---------------------------------------
  if ( "began" == event.phase ) then
    print("BEGAN")
    self.valueText.isVisible = false

    local xAbsPos, yAbsPos = self.nativeInput:localToContent(0,0)
    self.belowScreenHalf = yAbsPos - _H / 2

    if self.belowScreenHalf + 10 > 0 and self.screenGroup then
      if not self.screenGroup.originalY then
        self.screenGroup.originalY = self.screenGroup.y
      end

      self.moveUp = yAbsPos - _H / 2 + 30
      -- transition.to(self.screenGroup, { y = self.screenGroup.y - self.moveUp, time = 200 })
    end

    if self.onStartEditing then
      self.onStartEditing()
    end

    -- editace -----------------------------------------------
  elseif event.phase == "editing" then
    if self.onChange then
      self.onChange(self:value())
    end

    -- konec editace -----------------------------------------
  else
    self:hideKeyboard()
  end
end

function Input:setErrorMode()
  self.errorMode = true
  if self.border then
    self.border:setStrokeColor(1, 0, 0, 1)
    self.border:setFillColor(1, 0, 0, 0.02)
  end
  if self.label then
    self.label:setFillColor(1, 0, 0)
  end
end

function Input:clear()
  self.nativeInput.text = ""
  self.valueText.text = self.placeholder
end

function Input:shrink(offset)
  if not self.shrinkOffset or self.shrinkOffset == 0 then
    self.nativeInput.width = self.nativeInput.width - offset
    self.nativeInput.x = self.nativeInput.x - offset / 2
    self.border.width = self.border.width - offset
    self.shrinkOffset = offset
  end
end

function Input:unshrink()
  if self.shrinkOffset then
    self.nativeInput.width = self.nativeInput.width + self.shrinkOffset
    self.nativeInput.x = self.nativeInput.x + self.shrinkOffset / 2
    self.border.width = self.border.width + self.shrinkOffset
    self.shrinkOffset = nil
  end
end

function Input:moveScreenUp()
end

function Input:moveScreenDown()
end

function Input:value()
  return self.nativeInput.text
end

function Input:required()
  return self.options.required
end

return Input

