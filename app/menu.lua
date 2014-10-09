local composer = require( "composer" )
local scene = composer.newScene()

function scene:show(event)
  local group = self.view
  if ( event.phase == "will" ) then

  end
end

function scene:create(event)
  local group = self.view
end

function scene:hide(event)
  local group = self.view
  if ( event.phase == "will" ) then

  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)
scene:addEventListener( "hide", scene)

return scene
