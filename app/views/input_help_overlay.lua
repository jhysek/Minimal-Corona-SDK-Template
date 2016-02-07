local composer = require "composer"
local widget   = require "widget"
local Scaling  = require "lib.scaling"
local NavBar   = require "app.views.navBar"
local Button   = require "app.views.button"

local scene = composer.newScene()

function scene:redrawScene()
  if self.sceneGroup then
    self.sceneGroup:removeSelf()
  end
  self.sceneGroup = display.newGroup()

  local navigationBar = NavBar.create({
    title   = self.params.title,
    backBtn = {
      title = T:t("nav.back"),
      onTap = function() composer.hideOverlay("fade") end
    },
  })
  self.sceneGroup:insert(navigationBar)

  local scrollbox = widget.newScrollView({
    x      = _W / 2,
    y      = _H / 2 + navigationBar.height / 2 - 5,
    width  = _AW,
    height = _AH - navigationBar.height + 5
  })
  self.sceneGroup:insert(scrollbox)

  local offset = 10

  if self.params.text then
    local text = display.newText({
      x = 15,
      y = offset + 10,
      width = _AW - 30,
      align = 'left',
      font = native.systemFont,
      fontSize = 14,
      text = self.params.text
    })
    offset = offset + text.height
    text:setFillColor(0,0,0)
    text.anchorX = 0
    text.anchorY = 0
    scrollbox:insert(text)
  end

  if self.params.image then
    local image = display.newImage(self.params.image, self.params.dir, _AW / 2, offset + 10)
    image.anchorY = 0
    Scaling.scaleToFit(image, _AW, _H * 3)
    scrollbox:insert(image)
    offset = offset + image.contentHeight
  end

  print(_AW .. "x" .. _AH)
  local button = Button:new(scrollbox, offset + 30, T:t("nav.back"), "main", function() composer.hideOverlay("fade"); return true end, 200)
  scrollbox:setScrollHeight(offset + 100)

  self.view:insert(self.sceneGroup)
end

function scene:show(event)
  local params = event.params
  self.params = params
  if event.phase == 'will' then
    self:redrawScene()
  end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

return scene
