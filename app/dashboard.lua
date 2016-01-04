--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"

local Scaling  = require "lib.scaling"

local NavBar   = require "app.views.navBar"
local Button   = require "app.views.button"
local XML      = require "app.services.xml_generator"
local Server   = require "app.services.server"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local list
local navigationBar
local buttonGroup
local sceneGroup

local function newRating()
  composer.gotoScene("app.select_section", {
    effect = "slideLeft"
  })
end

local function aboutScene()
  composer.gotoScene("app.about", {
    effect = "slideLeft",
  })
end

local redrawList

local function onRowRender(event)
  local row = event.row
  local rating = row.params

  if row.isCategory then
    local bg = display.newRect(row, _W / 2, 30, _AW, 60)
    bg:setFillColor(0,0,0,0.1)

    local legend_fields = {
      {T:t("dashboard.date"), _L + 10},
      {T:t("dashboard.hunter"), _L + 65},
      {T:t("dashboard.trophy"), _L + _AW / 2 - 10},
      {T:t("dashboard.points"), _L + _AW / 4 * 3 - 40},
      {T:t("dashboard.medal"), _R - 80},
    }

    for i = 1, #legend_fields do
      local field = legend_fields[i]
      local legend = display.newText
      {
        parent = row,
        x = field[2],
        y = 30,
        width = _AW,
        font = native.systemFont,
        fontSize = 13,
        text = field[1],
        align = "left"
      }
      legend.anchorX = 0
      legend:setFillColor(0,0,0)
    end
  else

    local dateBg = display.newRect(row, 30, 30, 48, 58)
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
      x = _L + 65,
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
      x = _L + _AW / 2 - 10,
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
      x = _L + _AW / 4 * 3 - 15,
      text = rating.rating,
      font = native.systemFont,
      fontSize = 13,
      width = 50,
      align = "right",
      parent = row
    })
    points.anchorX = 1
    points:setFillColor(0,0,0)

    if rating.medal and rating.medal ~= 'none' then
      local medal = display.newImage(row, "assets/" .. rating.medal .. ".png", _R - 65, 30)
      Scaling.scaleToFit(medal, 35, 35)
    end

    local syncBg  = display.newRect(row, _R, 30, 70, row.height)
    syncBg.anchorX = 1
    syncBg.isHitTestable = true
    syncBg.isVisible = false
    syncBg:addEventListener("tap", function(e)
      Server.publishRating(rating, function()
        redrawList(sceneGroup)
      end)
    end)

    local filename = 'waiting'
    local rating = Rating:get(rating.id)
    if rating.sync_state then
      filename = rating.sync_state == 'ok' and "ok" or "exclamation"
    end

    local sync_state = display.newImage(row, 'assets/btn_' .. filename .. '.png', _R - 5, 30)
    sync_state.anchorX = 1
    Scaling.scaleToFit(sync_state, 25, 25)
  end
end

redrawList = function(group)
  if list then
    list:deleteAllRows()
    list:removeSelf()
    list = nil
  end

  list = widget.newTableView({
    top = navigationBar.bottom + 5,
    width = _AW,
    height = _AH - navigationBar.height - 60 - banner_height,
    onRowRender = onRowRender
  })

  list:insertRow({
    rowHeight = 60,
    isCategory = true,
    rowColor = { 0, 0, 0, 0.9},
    lineColor = { 0.90, 0.90, 0.90 },
  })

  Rating.orderBy = "sort_date DESC, id DESC"
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


function scene:redrawScene()
  local group = self.view

  if sceneGroup then
    sceneGroup:removeSelf()
  end
  sceneGroup = display.newGroup()
  group:insert(sceneGroup)

  navigationBar = NavBar.create({
    title   = T:t("dashboard.title")
  })
  sceneGroup:insert(navigationBar)

  buttonGroup = display.newGroup()
  buttonGroup.y = _B - 40
  sceneGroup:insert(buttonGroup)
  local newRatingBtn = Button:new(buttonGroup, 0, T:t("dashboard.new"), "main", newRating, (_AW - 60) / 2, _L + _AW / 2 - (_AW - 60) / 4 - 10)
  local aboutAppBtn = Button:new(buttonGroup, 0, T:t("dashboard.about"), "main", aboutScene, (_AW - 60) / 2, _L + _AW / 2 + (_AW - 60) / 4 + 10)

  redrawList(sceneGroup)
  showAd("banner", "bottom")
  buttonGroup.y = _B - 40 - banner_height
  buttonGroup:toFront()


  if Rating:count() == 0 then
    list.alpha = 0
    local text = display.newText
    {
      parent = sceneGroup,
      text = T:t("dashboard.no_ratings"),
      x = _W / 2,
      width = _AW - 30,
      y = _H / 2,
      font = native.systemFont,
      fontSize = 15,
      align = 'center'
    }
    text:setFillColor(0.1, 0.1, 0.1)
  end
end

function scene:show(event)
  if ( event.phase == "will" ) then
    self.redrawing = true
    self:redrawScene()
    self.redrawing = false
  end
end

Runtime:addEventListener("upload_finished", function()
  timer.performWithDelay(1000, function()
    if scene.redrawing or not list then
      timer.performWithDelay(500, function()
        redrawList(sceneGroup)
      end)
    else
      redrawList(sceneGroup)
    end
  end)
end)

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene
