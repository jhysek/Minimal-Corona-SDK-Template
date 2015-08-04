--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"
local NavBar   = require("app.views.navBar")
local Cam      = require("app.services.camera")
--------------------------------------------------------------------------------

local scene = composer.newScene()
local list
local navigationBar
local options
local preview_changed
local preview

local function goBack()
  composer.hideOverlay("slideRight", 100)
  os.remove( system.pathForFile("lastPhoto.png", system.TemporaryDirectory) )
end

local function fitScaleFactor(displayObject, fitWidth, fitHeight, enlarge)
  local scaleFactor = fitHeight / displayObject.height
  local newWidth = displayObject.width * scaleFactor
  if newWidth > fitWidth then
    scaleFactor = fitWidth / displayObject.width
  end
  if not enlarge and scaleFactor > 1 then
    return 1
  end
  return scaleFactor
end



function scene:create(event)
  local group = self.view

  local bg = display.newRect(group, _W / 2, _H / 2, _AW, _AH)
  bg:setFillColor(0.9,0.9,0.9,1)

  navigationBar = NavBar.create({
    title    = "",
    backBtn  = {
      title = "uložit",
      onTap = function(e)
        if options.onChanged and preview_changed then
          options.onChanged()
        end
        goBack()
      end
    },
    rightBtn = {
      image = "assets/icon_cancel.png",
      onTap = goBack
    }
  })
  group:insert(navigationBar)

  local tabs = widget.newTabBar({
    width = _AW,
    top   = _B - 58,
    buttons = {
      {
        width = 30,
        height = 30,
        id = "t1",
        label = "Vyfotit",
        defaultFile = "assets/icon_take_red.png",
        overFile = "assets/icon_take_red.png",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.7 } },
        onPress = function()
          Cam.take(function(img)
            if preview then
              preview:removeSelf()
            end
            preview = img
            preview.x = _W / 2
            preview.y = _H / 2
            group:insert(preview)
            local factor = fitScaleFactor(preview, _AW, _AH - 120)
            preview:scale(factor, factor)
            preview_changed = true
            navigationBar:toFront()
          end)

        end
      },

      {
        width = 30,
        height = 30,
        id = "t2",
        defaultFile = "assets/icon_pick_red.png",
        overFile = "assets/icon_pick_red.png",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.7 } },
        label = "Vybrat",
        onPress = function()
          print("Take")
          Cam.pick(function(img)
            if preview then
              preview:removeSelf()
            end
            preview = img
            if preview then
              group:insert(preview)
              preview.x = _W / 2
              preview.y = _H / 2
              local factor = fitScaleFactor(preview, _AW, _AH - 120)
              preview:scale(factor, factor)
              preview_changed = true
            end
            navigationBar:toFront()
          end)
        end
      },
    }
  })
  group:insert(tabs)
end

function scene:show(event)
  if event.phase == "will" then
    local group = self.view
    options = event.params

    if event.params then
      navigationBar.title.text = event.params.title
      if preview then
        preview:removeSelf()
      end

      if event.params.filename then
        preview = display.newImage(group, event.params.filename, event.params.path)
        preview_changed = false
        if preview then
          preview.x = _W / 2
          preview.y = _H / 2
          local factor = fitScaleFactor(preview, _AW, _AH - 100)
          preview:scale(factor, factor)
        end
      end
    else
      print("EEEAAEAEAEAEA NO PARAMS!")
    end
  end
end


function scene:hide(event)
  if event.phase == 'did' then
  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)
scene:addEventListener( "hide", scene)

return scene
