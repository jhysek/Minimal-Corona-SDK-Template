------------------------------------------------------------
_W = display.contentWidth
_H = display.contentHeight
_AW = display.actualContentWidth
_AH = display.actualContentHeight
_T = display.screenOriginY
_B = _T + _AH
_L = display.screenOriginX
_R = _L + _AW

display.setStatusBar( display.HiddenStatusBar )
display.setDefault("background", 1, 1, 1)
------------------------------------------------------------


inspect = require "lib.inspect"

require "lib.screenshot"

require "lib.string"
require "lib.settings"
require "app.db.schema"

appconfig = loadTable("config/config.json", system.ResourceDirectory) or {}

require "lib.set_language"
T = require("app.locales")

setLanguage()

require "lib.Ads"

local composer = require("composer")
composer.gotoScene("app.dashboard")

Runtime:addEventListener("orientation", function()
  _W = display.contentWidth
  _H = display.contentHeight
  _AW = display.actualContentWidth
  _AH = display.actualContentHeight
  _T = display.screenOriginY
  _B = _T + _AH
  _L = display.screenOriginX
  _R = _L + _AW

  local current_scene = composer.getScene(composer.getSceneName("current"))
  current_scene:redrawScene()

  local current_overlay = composer.getScene(composer.getSceneName("overlay"))
  if current_overlay then
    current_overlay:redrawScene()
  end
end)
