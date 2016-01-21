local widget   = require "widget"

local class    = require "lib.middleclass"
local Color    = require "lib.Color"
local _        = require "lib.underscore"
local MessageBox = class("MessageBox")

function MessageBox:onCreate()
end

function MessageBox:onShow()
end

function MessageBox:redraw()
  if self.group then
    self.group:removeSelf()
  end

  self.group = display.newGroup()
  self.parent:insert(self.group)

  -- overlay -------------------------------------------------------------------
  self.overlay = display.newRect(_W / 2, _H / 2, _W, _H)
  self.overlay:setFillColor(0,0,0,0.8)
  self.overlay.alpha = 0
  self.group:insert(self.overlay)
  self.overlay:addEventListener("tap", function() self:hide(); return true end)

  self.detailGroup = display.newGroup()
  self.detailGroup.xScale = 0.1
  self.detailGroup.yScale = 0.1
  self.detailGroup.alpha = 0
  self.detailGroup:addEventListener("tap", function() return true end)
  self.group:insert(self.detailGroup)

  -- background rect -----------------------------------------------------------
  local bg = display.newRect(_W / 2, _H / 2 - 20, math.min(_AW - 20, 500), self.options.height or 280)
  self.bg = bg
  bg:setFillColor(1, 1, 1, 1)
  bg:setStrokeColor(0.5, 0.5, 0.5)
  bg.strokeWidth = 5
  self.detailGroup:insert(bg)

  self:onCreate(self.detailGroup)
end

function MessageBox:initialize(parent, options)
  self.parent = parent
  self.options = options or {}
  self:redraw()
end

function MessageBox:show(data, onShow)
  if self.visible then
    return false
  end
  self.data = data
  self.visible = true

  self:onShow(data)

  transition.to(self.overlay, {
    alpha = 1,
    time = 800
  })

  self.group:toFront()
  self.detailGroup:toFront()
  self.detailGroup.x = _W / 2
  self.detailGroup.y = _H / 2
  transition.to(self.detailGroup, {
    time = 700,
    transition = easing.outExpo,
    xScale = 1,
    yScale = 1,
    x = 0,
    y = 0,
    alpha = 1,
    onComplete = function()
    end
  })
end

function MessageBox:hide()
  if self.onHide then
    self.onHide()
  end

  self.visible = false

  transition.to(self.overlay, {
    alpha = 0,
    time = 600
  })

  transition.to(self.detailGroup, {
    time = 500,
    transition = easing.outExpo,
    xScale = 0.1,
    yScale = 0.1,
    x = _W / 2,
    y = _W / 2,
    alpha = 0,
    onComplete = function(e)
      if onComplete then
        onComplete(e)
      end
    end
  })
end

function MessageBox:destroy()
  self.group:removeSelf()
end

function MessageBox:newText(text, x, y, options)
  options = options or {}

  local func = display.newText
  if options.emboss then
    func = display.newEmbossedText
  end

  local label = func(_.extend({
    parent = self.detailGroup,
    text = text,
    x = x,
    y = y,
    font = native.systemFont,
    fontSize = 15,
    align = "left"
  }, options))
  Color.setFillHexColor(label, options.color or "#000000")

  return label
end



return MessageBox
