--------------------------------------------------------------------------------
local class = require "lib.middleclass"
local Color = require "lib.Color"
--------------------------------------------------------------------------------

local Message = class("Message")

function Message.toast(text, options)
  local msg = Message:new(options)
  msg:show(text, nil, function()
    msg:destroy()
  end)
end

function Message:initialize(options)
  options = options or {}
  self.colors = {
    red   = {0.9, 0.2, 0.2, 0.9},
    green = {0.2, 0.9, 0.2, 0.9}
  }

  self.group = display.newGroup()
  self.autoHide = 3000
  self.height = _AH / 5
  self.currentTransition = nil
  self.group.alpha = 0
  self.options = options
  local bg = display.newRect(_W / 2, _T - self.height / 2, _W, self.height)
  Color.setFillHexColor(bg, self.colors[options.color] or options.color or appconfig.main_color, 0.8)
  self.group:insert(bg)

  self.label = display.newText({
    parent    = self.group,
    text      = "",
    textColor = {1, 1, 1, 1},
    fontSize  = 15,
    x = _W / 2,
    width = _AW - 40,
    height = self.height - 20
  })

  self.group:addEventListener("tap", function() self:hide() end)
  return self
end

function Message:stopTransition()
  if self.currentTransition then
    transition.cancel(self.currentTransition)
  end
end

function Message:show(text, onShow, onHide)
  self.label.text = text

  local target_y = _T + self.height / 2

  if self.options.position == "bottom" then
    self.group.y = _B + self.height
    target_y = _B - self.height / 2
  end

  self:stopTransition()
  self.currentTransition = transition.to(self.group, {
    time = 1000,
    alpha = 1,
    transition = easing.outExpo,
    y = target_y,
    onComplete = function()
      timer.performWithDelay(self.autoHide, function() self:hide(onHide) end)
      if onShow then
        onShow()
      end
      self.currentTransition = nil
    end
  })
end

function Message:hide(onComplete)

  self:stopTransition()
  self.currentTransition = transition.to(self.group, {
    time = 1000,
    alpha = 0,
    transition = easing.inExpo,
    y = _T - self.height / 2,
    onComplete = function(e)
      if onComplete then
        onComplete(e)
      end
      self.currentTransition = nil
    end
  })
end

function Message:destroy()
  self.group:removeSelf()
end

return Message

