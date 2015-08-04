local composer = require "composer"
local NavBar   = require "app.views.navBar"
local native   = require "native"
local scene = composer.newScene()

local params
local webview
local group

function scene:redrawScreen()
  if group then
    group:removeSelf()
  end

  group = display.newGroup()
  self.view:insert(group)

  local navigationBar = NavBar.create({
    title   = T:t("about.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.dashboard" },
  })

  webview = native.newWebView(_W / 2, _H / 2 + navigationBar.height / 2 - 2, _AW, _AH - navigationBar.height + 6)
  group:insert(webview)
  group:insert(navigationBar)

end

function scene:create(event)
  params = event.params
  self:redrawScreen()
end

function scene:show(event)
  params = event.params
  if ( event.phase == "will" ) then
    if params.url then
      webview.isVisible = true
      webview:request(params.url, system.ResourceDirectory)
    end
  end
end

function scene:hide(event)
  if ( event.phase == "will" ) then
    webview:stop()
    webview:request("")
    webview.isVisible = false
  end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
