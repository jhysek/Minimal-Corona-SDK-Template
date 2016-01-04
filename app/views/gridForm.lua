--------------------------------------------------------------------------------
local widget  = require "widget"
local composer = require "composer"
local class   = require "lib.middleclass"
local Color   = require "lib.Color"
local _       = require "lib.underscore"
local Utils   = require "lib.utils"
local Files   = require "lib.copy_file"

local GridView = require "app.views.gridView"
local TableSelectInput = require "app.views.table_select_input"
local Input    = require "app.views.input"
local BoolInput = require "app.views.bool_input"
local DateInput = require "app.views.date_input"
--------------------------------------------------------------------------------

local Form = class("Form")

function Form:redraw()
  if self.group then
    self.group:removeSelf()
  end
  self.group = display.newGroup()

  self.fieldList = GridView:new(
  self.group,
  _W / 2,
  _AH / 2 - 30,
  self.options.width or _AW,
  self.options.height or _AH - 60,
  {
    padding = 0,
    columns = 1,
    item_height = 50,
    horizontalScrollDisabled = true
  }
  )

  self:reloadItems()
  self.parent:insert(self.group)
end

function Form:initialize(parent, fields, options)
  self.parent = parent
  self.options = options or {}
  self.fields = fields
  self.inputs = {}
  self.errors = {}

  self:redraw()

end

function Form:removeSelf()
  if self.group then
    self.group:removeSelf()
  end
end

function Form:values()
  result = {}
  for name, input in pairs(self.inputs) do
    result[name] = input:value()
  end
  return result
end

function Form:setValues(values)
  for name, input in pairs(self.inputs) do
    if values[name] then
      input:setValue(values[name])
    end
  end
end

function Form:clear()
  for name, input in pairs(self.inputs) do
    input:clear()
  end
end

-- validace konkretniho inputu -------------------------------------------------
function Form:inputIsValid(input, validations)
  if input then
    local errors = {}
    local value = input:value()

    for validation, args in pairs(validations) do
      if (validation == "presence" and (value == "" or not value)) or
        (value and value ~= "" and validation == "numeric" and (tonumber(string.gsub(value, ",", "."), 10) == nil)) then

        errors[#errors + 1] = validation
        input:setErrorMode()

        input.label:setFillColor(1,0,0)
      end
    end

    input.errors = errors
    return #errors == 0
  end
end

-- validace celeho formulare ---------------------------------------------------
function Form:validate()
  local result = true
  self.errors = {}

  for i = 1,#self.fields do
    local field = self.fields[i]
    if field.validations then
      if not self:inputIsValid(self.inputs[field.name], field.validations) then
        if self.inputs[field.name] then
          self.errors[field.name] = self.inputs[field.name].errors
        end
        result = false
      end
    end
  end

  return result
end

function Form:submit()
  if self:validate() then
    if self.onSubmit then
      self.onSubmit(self:values())
    end
  else
    if self.onValidationFailed then
      self.onValidationFailed(self.errors)
    end
  end
end

function Form:reloadItems()
  self.fieldList:clear()

  for i = 1,#self.fields do
    local field = self.fields[i]

    local row = display.newGroup()
    row.index = i
    row.params = field

    local bg = display.newRect(row, 0, 0, _AW, self.fieldList.options.item_height)
    bg:setFillColor(1,1,1)

    self:renderItem({ row = row })
    self.fieldList:insert(row)

    if field.type ~= 'section' then
      local line = display.newRect(row, 0, self.fieldList.options.item_height / 2 - 1, _AW, 1)
      line:setFillColor(0,0,0,0.2)
    end

    bg:addEventListener("tap", function(e)
      self:touchItem({ row = row })
    end)
  end

  self.fieldList:redraw()
end

function Form:touchItem(event)
  local row = event.row
  local idx = row.index
  local field = event.row.params

  if not self.readOnly then
    if field.type == "button" then
      if field.onTap then
        field.onTap(self)
      end

    elseif field.type == "submit" then
      self:submit()

    elseif self.inputs[field.name] then
      self.inputs[field.name]:setFocus()
    end
  end

  return true
end

function Form:redrawPhotosField(row, field)
  row.objects = row.objects or {}

  if #row.objects > 0 then
    for i = 1, #row.objects do
      row.objects[i]:removeSelf()
      row.objects[i] = nil
      print("REMOVED CONTAINER #" .. i)
    end
  end

  for i = 1, field.count do
    local c_height  = row.height - 10
    local c_width   = c_height / 3 * 4
    local container = display.newContainer(row, c_width, c_height)
    container.x = _AW / 2 - (c_width + 10) * i + c_width / 2
    container.y = 0
    row.objects[i] = container

    local bg
    local params = {}
    if field.images[i] then
      params.filename = field.images[i]
      params.path     = system.DocumentsDirectory
      bg = display.newImage(container, field.images[i], system.DocumentsDirectory)
    else
      bg = display.newImage(container, "assets/img_placeholder.png")
    end

    params.onChanged = function()
      field.images[i] = "photos_" .. os.time() .. ".jpg"
      Files.copyFile("lastPreview.jpg", system.TemporaryDirectory,
                     field.images[i], system.DocumentsDirectory)

      self:redrawPhotosField(row, field)
    end

    if bg then
      bg.width = c_width
      bg.height = c_height

      bg:addEventListener("tap", function()
        native.setKeyboardFocus(nil)
        composer.showOverlay("app.views.table_input_photo", {
          isModal = true,
          effect = "slideLeft",
          time = 400,
          params = params
        })
      end)
    end
  end
end

function Form:renderItem(event)
  local row = event.row
  local idx = row.index
  local field = event.row.params

  local label_align = "left"
  local label_width = self.fieldList.width * (self.options.label_width or 0.6)
  local input_width = self.fieldList.width - label_width
  local label_font_size = 15
  local label_x = -_AW/2 + 20
  local label_color = "#000000"

  -- text / password input -----------------------------------------------------
  if not field.type or field.type == "text" or field.type == "password" then
    local input = Input:new(row,
    self.fieldList.options.item_width / 2 - input_width / 2 - 5,
    0, -- self.fieldList.options.item_height / 2,
    input_width,
    {
      placeholder = field.placeholder,
      isSecure = field.type == "password",
      --      inputFillColor = "#ffffff",
      inputBorderWidth = 0,
      screenGroup = self.parent,
      value = field.default,
      readOnly = self.options.readOnly,
      value_align = self.options.value_align,
      value_padding_right = self.options.value_padding_right,
      value_font_size = self.options.value_font_size,
      gridView = self.fieldList,
      input_type = field.input_type
    })
    self.inputs[field.name] = input
  end

  if field.type == 'boolean' then
    local input = BoolInput(row,
    self.fieldList.options.item_width / 2 - input_width / 4 * 3,
    0,
    input_width,
    {})
    self.inputs[field.name] = input
  end

  if field.type == 'date' then
    local currYear = tonumber(os.date("%Y"))
    local currMonth = tonumber(os.date("%m"))
    local currDay = tonumber(os.date("%d"))

    local input = DateInput(row,
    self.fieldList.options.item_width / 2 - input_width / 4 * 3,
    0,
    input_width,
    {
      value = currDay .. "." .. currMonth .. ". " .. currYear
    })
    self.inputs[field.name] = input
  end


  if field.type == 'select' then
    local input = TableSelectInput:new(row, _AW - input_width - 5, 0, input_width, _.extend(field, {
      placeholder = field.placeholder,
      value = field.default,
      height = row.height,
      readOnly = self.readOnly
    }))

    self.inputs[field.name] = input
  end

  -- photos --------------------------------------------------------------------
  if field.type == "photos" then
    self:redrawPhotosField(row, field)
  end

  -- button --------------------------------------------------------------------
  if field.type == "button" or field.type == "submit" then
    local bg = display.newRect(row, 0, 0, row.width, row.height)
    if field.onTap then
      bg:addEventListener("onTap", field.onTap)
    end
    Color.setFillHexColor(bg, appconfig.main_color)
    label_color = "#ffffff"
    label_align = 'center'
    label_font_size = 20
    label_x = - self.fieldList.options.item_width / 2
    label_width = self.fieldList.width
  end

  -- section -------------------------------------------------------------------
  if field.type == 'section' then
    label_color = "#333333"
    label_font_size = 13
    label_align = 'center'
    label_width = self.fieldList.width - 20
    label_x = - self.fieldList.options.item_width / 2 + 10
  end

  -- image ---------------------------------------------------------------------
  if field.type == "image" then
    local img = display.newImage(row, field.filename)
    if img then
      local factor = Utils.fitScaleFactor(img, _AW, field.height - 10)

      img:scale(factor, factor)
      img.x = _AW / 2
      img.y = field.height / 2
    end
  end

  -- label ---------------------------------------------------------------------
  if field.type ~= 'separator' and field.type ~= 'image' then
    local label = display.newText({
      text = field.label or field.name or "NO LABEL",
      fontSize = label_font_size,
      font = native.systemFont,
      x = label_x,
      width = label_width - 10,
      align = label_align,
      y = 0 -- self.fieldList.options.item_height / 2
    })
    label.anchorX = 0
    Color.setFillHexColor(label, label_color)
    row:insert(label)

    if self.inputs[field.name] then
      self.inputs[field.name].label = label
    end
  end

end


return Form

