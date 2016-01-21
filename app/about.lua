--------------------------------------------------------------------------------
local composer = require "composer"
local _        = require "lib.underscore"
local NavBar   = require "app.views.navBar"
local Server   = require "app.services.server"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local navigationBar

function scene:newText(x, y, text, options)
  options = options or {}

  local label = display.newText(
  _.extend({
    parent = self.sceneGroup,
    text = text,
    x = x,
    y = y,
    font = options.font or native.systemFont,
    fontSize = 15,
    align = "center",
    width = _AW - 20,
  }, options)
  )
  label.anchorY = 0

  if options.url then
    label:addEventListener("tap", function() system.openURL(options.url) end)
  end

  Color.setFillHexColor(label, options.color or "#333333")
  return label
end

function scene:redrawScene()
  local group = self.view
  if self.sceneGroup then
    self.sceneGroup:removeSelf()
  end
  self.sceneGroup = display.newGroup()
  group:insert(self.sceneGroup)

  navigationBar = NavBar.create({
    backBtn = { title = T:t("nav.back"), scene = "app.dashboard" },
    title   = T:t("about.title")
  })
  self.sceneGroup:insert(navigationBar)

  local l1 = self:newText(_W/2, _T + 100, T:t("about.app_name"), { fontSize = 25 })
  local l2 = self:newText(_W/2, _T + 140, T:t("about.version") .. ": " .. appconfig.version)
  local l3 = self:newText(_W/2, _T + 170, T:t("about.copyright"))

  local l4 = self:newText(_W/2, _T + 200, T:t("about.info1"))
  local l5 = self:newText(_W/2, _T + 230, T:t("about.info2"))
  local l6 = self:newText(_W/2, l5.y + l5.height + 10, T:t("about.info3"), { url = appconfig.www })
  local l7 = self:newText(_W/2, l6.y + l6.height + 10, T:t("about.info4"))

  local icon = display.newImage(self.sceneGroup, "assets/icon.png", _W / 2, l7.y + l7.height + 30)
  icon:addEventListener("tap", function() Server.publishServiceInfo() end)
  icon.anchorY = 0
end


function scene:show(event)
  if event.phase == 'will' then
    self:redrawScene()
  end
end

scene:addEventListener( "show", scene)

return scene
