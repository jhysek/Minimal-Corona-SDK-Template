local composer = require "composer"

function saveScreenshot()
  local scene = composer.getScene(composer.getSceneName("current"))
  if scene and scene.view then
    print("UKLADAM SCREENSHOT: " .. display.pixelWidth .. 'x' .. display.pixelHeight .. '_' .. math.floor(system.getTimer()) .. '.png')
    display.save(scene.view, display.pixelWidth .. 'x' .. display.pixelHeight .. '_' .. math.floor(system.getTimer()) .. '.png')
  end
end

local ss_rect = display.newRect(_R - 30, _T + 30, 60, 60)
ss_rect.isHitTestable = true
ss_rect.isVisible     = false
ss_rect:addEventListener("tap", saveScreenshot)

Runtime:addEventListener('key', function (event)
  if event.keyName == 's' and event.phase == 'down' then
    saveScreenshot()
    return true
  end
end)
