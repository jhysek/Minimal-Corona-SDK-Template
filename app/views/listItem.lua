--------------------------------------------------------------------------------
local class    = require "lib.middleclass"
local widget   = require "widget"
local Color    = require "lib.Color"
local _        = require "lib.underscore"
--------------------------------------------------------------------------------

local ListItem = class("ListItem")

function ListItem:initialize(options)
  options = options or {}
  self.group = options.group or display.newGroup()
  self.displayObject = self.group
  self.options = options

  self.bg = display.newRect(options.width / 2 + 2, options.height / 2, options.width, options.height)

  if options.asButton then
    Color.setFillHexColor(self.bg, options.bgColor or "#eaeaea", 0.9)
    self.bg.strokeWidth = 0
    self.bg.isVisible = false
    self.bg.isHitTestable = true
  else
    self.bg.isHitTestable = true
    self.bg.isVisible = false
  end

  if options.bgColor then
    self.bg.isVisible = true
    Color.setFillHexColor(self.bg, options.bgColor)
  end
  self.group:insert(self.bg)

  if not options.asButton then
  --   line.alpha = 0.4
  --   line.x = self.options.width / 2
  --   line.y = 0
  else
    local line = display.newImage(self.group, "assets/line_dark.png")
     line.x = self.options.width / 2
     line.y = 0
    line.width = self.bg.width
   end

  local x = 10
  if options.title then
    if options.leftImage then
      x = x + options.height + 10
    end

    self.title = display.newText({
      y = options.height / 2,
      x = x,
      text = options.title,
      font = "Helvetica Neue",
      fontSize = options.asButton and 15 or 15,
      align = "left"
    })
    self.title.anchorX = 0

    print("TITLE: " .. self.title.text)
    Color.setFillHexColor(self.title, options.titleColor or "#000000", 0.9)
    self.group:insert(self.title)
  end

  if options.subtitle and string.len(options.subtitle) > 0 then
    self.title.y = options.height / 3
    self.subtitle = display.newText({
      y = options.height / 3 + 13,
      x = x,
      text = options.subtitle,
      font = "Helvetica Neue",
      fontSize = 12,
      align = "left",
      width = options.width - 40
    })
    self.subtitle.anchorX = 0
    self.subtitle.anchorY = 0
    self.subtitle:setFillColor(0, 0, 0, 0.6)
    self.group:insert(self.subtitle)
  end

  if options.leftImage then
    self:setLeftImage(options.leftImage)
  else
    -- if self.title then
    --   self.title.x = - (options.width / 2) + 10
    -- end
    -- if self.subtitle then
    --   self.subtitle.x = - (options.width / 2) + 10
    -- end
  end

  if options.rightText then
    self.rightText = display.newText({
      y = options.height / 2,
      x = options.width - 15,
      text = options.rightText,
      font = "Helvetica Neue",
      fontSize = options.rightTextSize or 17,
      width = 200,
      align = "right"
    })
    self.rightText.anchorX = 1
    Color.setFillHexColor(self.rightText, options.rightTextColor or appconfig.main_color)
--    self.rightText:setFillColor(0, 0, 0, 0.6)
    self.group:insert(self.rightText)
  elseif options.rightGroup then
    self.rightGroup = options.rightGroup
    options.rightGroup.y = self.options.height / 2
    options.rightGroup.anchorX = 0
    options.rightGroup.x = options.width - 80
    self.group:insert(options.rightGroup)

  else
    local rightArrow = display.newImage(self.group, "assets/right.png", options.width - 20, options.height / 2)

    rightArrow.alpha = 0.4
    rightArrow:scale(0.5, 0.5)
  end

  if options.onTap then
    self.bg:addEventListener("tap", function()
      print("TAP")
      options.onTap()
      return true
    end)
  end
end


function ListItem:setLeftImage(img)
  if self.image then
    self.image:removeSelf()
    self.title.x = 10
  end

  if type(img) == 'table' then
    self.image = img
    self.group:insert(self.image)
  else
    self.image = display.newImage(self.group, img)
  end

  if self.image then
    self.title.x = self.options.height + 10
    self.image.anchorX = 0
    self.image.x = 10
    self.image.y = self.options.height / 2
    local scale = 40 / self.image.width
    if self.options.height < 40 then
      scale = (self.options.height - 10) / self.image.height
    end

    if scale < 1 then
      -- self.image.scale = scale
      self.image.xScale = scale
      self.image.yScale = scale
    end
  end
end

function ListItem:zoomLeftImage()
  if self.image then
    self.image:toFront()
    transition.to(self.image, {
      xScale = 1,
      yScale = 1,
      transition = easing.outExpo,
      onComplete = function()
        self.image:addEventListener("tap", function()
          transition.to(self.image, { xScale = self.image.scale, yScale = self.image.scale, time = 500, transition = easing.outExpo })
          return true
        end)
    end})
  end
end

return ListItem
