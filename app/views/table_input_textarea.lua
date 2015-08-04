--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"
local NavBar   = require("app.views.navBar")
--------------------------------------------------------------------------------

local scene = composer.newScene()
local list
local navigationBar
local options
local text

local function goBack()
  composer.hideOverlay("slideRight", 100)
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
        if options.onChanged then
          options.onChanged(text.text)
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

  -- vytvorit textview
  text = native.newTextBox(_W / 2, navigationBar.height + 150 / 2, _AW, 150)
  text.isEditable = true
  group:insert(text)
end

function scene:show(event)
  if event.phase == "will" then
    options = event.params
    native.setKeyboardFocus(text)

    if event.params then
      navigationBar.title.text = event.params.title
      text.text = event.params.value or ""
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
