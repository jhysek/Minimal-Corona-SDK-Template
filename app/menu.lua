local scene = storyboard.newScene()

function scene:willEnterScene(event)
  group = self.view
end

function scene:createScene(event)
  group = self.view
end

function scene:willExitScene(event)
  group = self.view
end

scene:addEventListener( "createScene", scene)
scene:addEventListener( "willEnterScene", scene)
scene:addEventListener( "willExitScene", scene)

return scene
