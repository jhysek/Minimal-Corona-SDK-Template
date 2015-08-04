--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"

local Utils    = require "lib.utils"

local NavBar   = require "app.views.navBar"
local Button   = require "app.views.button"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local list
local navigationBar
local buttonGroup

local function newRating()
  composer.gotoScene("app.select_section", {
    effect = "slideLeft"
  })
end

local function aboutScene()
  composer.gotoScene("app.webview", {
    effect = "slideLeft",
    params = {
      url = T:t('about.filename')
    }
  })
end

local function onRowRender(event)
  local row = event.row
  local rating = row.params

  if row.isCategory then
    local bg = display.newRect(row, _W / 2, 30, _AW, 60)
    bg:setFillColor(0,0,0,0.1)

    local legend = display.newText
    {
      parent = row,
      x = _W / 2,
      y = 30,
      font = native.systemFont,
      fontSize = 14,
      text = "Lov           Lovec                 Trofej            Bodů    Medaile",
      align = "left"
    }
    legend:setFillColor(0,0,0)
  else

    local dateBg = display.newRect(row, 30, 30, 58, 58)
    Color.setFillHexColor(dateBg, appconfig.main_color)
    local date = display.newText({
      y = 30,
      x = _L + 10,
      text = rating.date or "",
      font = native.systemFont,
      fontSize = 14,
      width = 58,
      align = "left",
      parent = row
    })
    date.anchorX = 0
    date:setFillColor(1,1,1)

    local hunter = display.newText({
      y = 30,
      x = _L + 70,
      text = rating.hunter,
      font = native.systemFont,
      fontSize = 13,
      width = 80,
      align = "left",
      parent = row
    })
    hunter.anchorX = 0
    hunter:setFillColor(0,0,0)

    local section = display.newText({
      y = 30,
      x = _L + 175,
      text = T:t("title." .. rating.animal),
      font = native.systemFont,
      fontSize = 13,
      width = 80,
      align = "left",
      parent = row
    })
    section.anchorX = 0
    section:setFillColor(0,0,0)

    local points = display.newText({
      y = 30,
      x = _L + 255,
      text = rating.rating,
      font = native.systemFont,
      fontSize = 13,
      width = 60,
      align = "left",
      parent = row
    })
    points.anchorX = 0
    points:setFillColor(0,0,0)

    if rating.medal and rating.medal ~= 'none' then
      local medal = display.newImage(row, "assets/" .. rating.medal .. ".png", _R - 30, 30)
      local factor = Utils.fitScaleFactor(medal, 50, 50)
      medal:scale(factor, factor)
    end

  end

end


local function redrawList(group)
  if list then
    list:deleteAllRows()
    list:removeSelf()
  end

  print("BANNER HEIGHT: " .. banner_height)

  list = widget.newTableView({
    top = navigationBar.bottom,
    width = _AW,
    height = _AH - navigationBar.height - 120 - banner_height,
    onRowRender = onRowRender
  })

  list:insertRow({
    rowHeight = 60,
    isCategory = true,
    rowColor = { 0, 0, 0, 0.9},
    lineColor = { 0.90, 0.90, 0.90 },
  })

  Rating.orderBy = "date"
  Rating:all(function(r)
    list:insertRow({
      rowHeight = 60,
      isCategory = false,
      rowColor = { 1, 1, 1 },
      lineColor = { 0.90, 0.90, 0.90 },
      params = r
    })
  end)
  group:insert(list)
end

function scene:show(event)
  local group = self.view
  if ( event.phase == "will" ) then
    redrawList(group)
    showAd("banner", "bottom")
    buttonGroup.y = - banner_height
  end
end

function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title   = T:t("dashboard.title")
  })
  group:insert(navigationBar)

  buttonGroup = display.newGroup()
  group:insert(buttonGroup)
  local newRatingBtn = Button:new(buttonGroup, _B - 40, T:t("dashboard.new"), "main", newRating, (_AW - 60) / 2, _L + _AW / 2 - (_AW - 60) / 4 - 10)
  local aboutAppBtn = Button:new(buttonGroup, _B - 40, T:t("dashboard.about"), "main", aboutScene, (_AW - 60) / 2, _L + _AW / 2 + (_AW - 60) / 4 + 10)
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene