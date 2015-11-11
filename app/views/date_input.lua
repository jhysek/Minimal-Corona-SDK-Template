--------------------------------------------------------------------------------
local widget = require "widget"

local class = require "lib.middleclass"

widget.setTheme("widget_theme_ios7")
require "lib.datePickerWheel"

local GenericInput = require "app.views.generic_input"
local Button       = require "app.views.button"
--------------------------------------------------------------------------------

local DateInput = class("DateInput", GenericInput)

function DateInput:drawInput()

  local text = display.newText
  {
    parent = self.group,
    fontSize = 13,
    font = system.nativeFont,
    x = 10,
    y = 0,
    text = self.input_value or T:t("date_input.placeholder"),
    align = "left",
    width = self.options.width
  }
  text:setFillColor(0,0,0)
end

function DateInput:onAccept()
  local values = self.datePicker:getValues()
  self.input_value = values[1].value .. ". " .. values[2].index .. ". " .. values[3].value
  display.remove(self.pickerGroup)

  self.picker_values = values
  self:redraw()
end

function DateInput:cancel()
  display.remove(self.pickerGroup)
end

function DateInput:orientation(event)
  self:cancel()
end

function DateInput:setFocus()
  native.setKeyboardFocus(nil)
  self.pickerGroup = display.newGroup()
  self.pickerGroup.y = _T

  local overlay = display.newRect(self.pickerGroup, _W / 2, _H / 2, _AW, _H)
  overlay:setFillColor(0,0,0, 0.8)
  overlay:addEventListener("tap", function() self:cancel() end)

  -- zobrazi se widget
  local currYear = tonumber(os.date("%Y"))
  local currMonth = tonumber(os.date("%m"))
  local currDay = tonumber(os.date("%d"))

  if self.picker_values then
    currYear = self.picker_values[3].value
    currMonth = self.picker_values[2].index
    currDay = self.picker_values[1].index
  end

  local datePicker = widget.newDatePickerWheel(currYear, currMonth, currDay)
  datePicker.anchorChildren = true
  datePicker.anchorX = 0.5
  datePicker.anchorY = 0
  datePicker.x = display.contentCenterX
  datePicker.y = _T + 20
  self.datePicker = datePicker

  local bg = display.newRect(self.pickerGroup, _W / 2, datePicker.y - 10, datePicker.width, datePicker.height + 80)
  bg.anchorY = 0
  bg:setFillColor(0.9, 0.9, 0.9, 1)
  bg:addEventListener("tap", function() return true end)

  local okBtn = Button:new(
    self.pickerGroup,
    _T + 55 + datePicker.height,
    T:t("new_rating_step_2.choose"), "main", function() self:onAccept(); return true end,
    (bg.width - 10) / 2,
    _L + _AW / 2 - (bg.width - 10) / 4 - 5)

  local cancelBtn = Button:new(
    self.pickerGroup,
    _T + 55 + datePicker.height,
    T:t("new_rating_step_2.cancel"), "gray", function() self:cancel(); return true end,
    (bg.width - 10) / 2,
    _L + _AW / 2 + (bg.width - 10) / 4 + 5)

  self.pickerGroup:insert(datePicker)

  Runtime:addEventListener("orientation", self)
end

return DateInput
