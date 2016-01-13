local composer = require "composer"

Runtime:addEventListener('key', function (event)
  if event.keyName == 's' and event.phase == 'down' then
    local scene = composer.getScene(composer.getSceneName("current"))
    if scene and scene.view then
      print("UKLADAM SCREENSHOT: " .. display.pixelWidth .. 'x' .. display.pixelHeight .. '_' .. math.floor(system.getTimer()) .. '.png')
      display.save(scene.view, display.pixelWidth .. 'x' .. display.pixelHeight .. '_' .. math.floor(system.getTimer()) .. '.png')
      return true
    end
  end
end)
