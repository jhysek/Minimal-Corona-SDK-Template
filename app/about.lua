--------------------------------------------------------------------------------
local composer = require "composer"
local _        = require "lib.underscore"
local NavBar   = require "app.views.navBar"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local navigationBar

function scene:newText(x, y, text, options)
  options = options or {}

  local label = display.newText(
    _.extend({
      parent = self.view,
      text = text,
      x = x,
      y = y,
      font = options.font or native.systemFont,
      fontSize = 15,
      align = "center",
      width = _AW - 20,
    }, options)
  )

  Color.setFillHexColor(label, options.color or "#333333")
end


function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    backBtn = { title = T:t("nav.back"), scene = "app.dashboard" },
    title   = T:t("about.title")
  })
  group:insert(navigationBar)

  self:newText(_W/2, _T + 120, T:t("about.app_name"), { fontSize = 25 })
  self:newText(_W/2, _T + 160, T:t("about.version") .. ": " .. appconfig.version)
  self:newText(_W/2, _T + 190, T:t("about.copyright"))

  for idx = 1, #T:t("about.info") do
    self:newText(_W/2, _T + 220 + (idx - 1) * 30, T:t("about.info")[idx])
  end
end

scene:addEventListener( "create", scene)

return scene
