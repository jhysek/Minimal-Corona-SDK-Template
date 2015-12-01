--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"

local Scaling  = require "lib.scaling"

local NavBar   = require "app.views.navBar"
local Cam      = require "app.services.camera"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local list
local tabs
local navigationBar
local options
local preview_changed
local preview

local function goBack()
  composer.hideOverlay("slideRight", 100)
  os.remove( system.pathForFile("lastPhoto.png", system.TemporaryDirectory) )
end

function scene:clearPreview()
  print("CLEARING PREVIEW")
  if preview then
    print("EXISTS, removing")
    preview:removeSelf()
  end
  print("CREATING NEW ONE")
  preview = display.newContainer(self.view, _AW, _AW - 120)
  preview.x = _W / 2
  preview.y = _H / 2
end

function scene:create(event)
  local group = self.view

  local bg = display.newRect(group, _W / 2, _H / 2, _AW, _AH)
  bg:setFillColor(0.9,0.9,0.9,1)

  navigationBar = NavBar.create({
    title    = "",
    no_cart  = true,
    backBtn  = {
      title = "uložit",
      fg_color = "#ffffff",
      onTap = function(e)
        display.save(preview, {
          filename = "lastPreview.jpg",
          baseDir  = system.TemporaryDirectory
        })
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

  self:clearPreview()

  local tabs_bg = display.newRect(group, _W / 2, _B - 58 - banner_height, _AW, 58)
  tabs_bg.anchorY = 0
  tabs_bg:setFillColor(0.97, 0.97, 0.97)

  local btn_take = display.newImage(group, "assets/icon_take.png", _L + _AW / 4, _B - 30 - banner_height)
  Scaling.scaleToFit(btn_take, 30, 30)
  local btn_pick = display.newImage(group, "assets/icon_pick.png", _R - _AW / 4, _B - 30 - banner_height)
  Scaling.scaleToFit(btn_pick, 30, 30)

  btn_take:addEventListener("tap", function()
    Cam.take(function(img)
      self:clearPreview()
      if img then
        print("inserting img to preview")
        preview:insert(img)
        Scaling.scaleToFit(img, _AW, _AH - 120)
        preview_changed = true
      end
      navigationBar:toFront()
    end)
  end)

  btn_pick:addEventListener("tap", function()
    Cam.pick(function(img)
      self:clearPreview()
      if img then
        preview:insert(img)
        Scaling.scaleToFit(img, _AW, _AH - 120)
        preview_changed = true
      end
      navigationBar:toFront()
    end)
  end)
end

function scene:show(event)
  if event.phase == "will" then
    native.setKeyboardFocus(nil)
    local group = self.view
    options = event.params

    if event.params then
      navigationBar.title.text = event.params.title
      self:clearPreview()

      if event.params.filename then
        preview_changed = false
        local img = display.newImage(preview, event.params.filename, event.params.path)
        if img then
          Scaling.scaleToFit(img, _AW, _AH - 120)
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
