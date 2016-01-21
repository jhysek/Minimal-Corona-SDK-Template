local composer = require( "composer" )
local _         = require "lib.underscore"
local Text      = require "app.views.text"
local Color     = require "lib.Color"

local navBar = {
  defaults = {
    height = 62,
    -- bg_color = {1, 1, 1, 0.9},
    bg_color = {1, 1, 1, 1},
    fg_color = {0, 0, 0, 0.8}
  }
}

local function setTextColor(text, colorTable)
  colorTable[4] = colorTable[4] or 1
  text:setFillColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
end

local function goBackTo(sceneName, backeffect, params)
  native.setKeyboardFocus(nil)
  composer.gotoScene(sceneName, {
    time = 200,
    effect = backeffect or "slideRight",
    params = params
  })
end

local function createNavBarTitle(group, options)
  if options then

    if type(options) == "string" then
      local title = Text.createText(group, options, _AW / 2, _T + 32, { fontSize = 16 })
      Color.setFillHexColor(title, options.titleColor or appconfig.main_color)
      title:setFillColor(1,1,1)
      group.title = title

    elseif type(options) == "table" then
      local title

      if options.type == "image" then
        title = display.newImage(group, options.path, group.width / 2, 38)

        if title.width > _AW / 2.5 then
          local scale_ratio = (_AW / 2.5) / title.width
          title:scale(scale_ratio, scale_ratio)
        elseif title.height > 40 then
          local scale_ratio = 40 / title.height
          title:scale(scale_ratio, scale_ratio)
        end
      end

      if title and options.onTap then
        title:addEventListener("tap", options.onTap)
      end
    end
  end
end

local function createNavBarBackBtn(group, options)
  if options then
    local backBtn = display.newGroup()
    backBtn.x = _L + 20
    backBtn.y = _T + 30

    local clickable = display.newRect(backBtn, _L, 0, 120, 60)
    clickable.isHitTestable = true
    clickable.isVisible = false

    backBtn.label = display.newText({
      parent = backBtn,
      text = options.title,
      fontSize = 17,
      x = 27,
      y = 1,
      font = "Helvetica Neue"
    })
    Color.setFillHexColor(backBtn.label, options.fg_color or appconfig.main_color)

    local arrow = display.newImageRect(backBtn, "assets/back-white.png", 30, 21)
    arrow.x = 5
    arrow.y = 2

    if options.onTap then
      clickable:addEventListener("tap", function() options.onTap() end)
    else
      clickable:addEventListener("tap", function() goBackTo(options.scene, options.effect, options.params) end)
    end
    group:insert(backBtn)
  end
end

local function createNavBarRightBtn(group, options)
  if options then
    local bg = display.newRect(group, _R - 30, _T + 33, 60, 60)
    bg.isVisible     = false
    bg.isHitTestable = true

    -- if options.image then
      local rightBtn = display.newImageRect(group, options.image, 25, 25, 0, 5)
      if rightBtn then
        rightBtn.x = _R - 30
        rightBtn.y = _T + 30
        -- Color.setFillHexColor(rightBtn, appconfig.main_color)
      end
    -- end

    if options.onTap then
      bg:addEventListener("tap", function(e) options.onTap(e); return true end)
    end

    group.rightBtn = rightBtn
  end
end


function navBar.create(options)
  options = options or {}
  local bar = display.newGroup()

  local bar_height = options.height or navBar.defaults.height
  local bg_color  = options.bg_color or navBar.defaults.bg_color

  local bg = display.newRect(bar, _W / 2, _T, _W, bar_height + 5)
  bg:addEventListener("tap", function(e) return true end)
  bg.anchorY = 0
  Color.setFillHexColor(bg, appconfig.main_color)

  local bottomLine = display.newLine(_L, _T + bar_height + 5, _R, _T + bar_height + 5)
  bottomLine:setStrokeColor(0.8, 0.8, 0.8)
  bottomLine.strokeWidth = 1
  bar:insert(bottomLine)

  createNavBarBackBtn(bar, options.backBtn)
  createNavBarTitle(bar, options.title)
  createNavBarRightBtn(bar, options.rightBtn)

  bar.bottom = _T + bar_height
  return bar
end


return navBar
