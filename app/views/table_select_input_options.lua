--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"
local NavBar   = require("app.views.navBar")
--------------------------------------------------------------------------------

local scene = composer.newScene()
local list
local navigationBar
local options
local hiding

local function goBack()
  if not hiding then
    hiding = true
    composer.hideOverlay("slideRight", 100)
  end
end

local function reloadItems(items, value)
  list:deleteAllRows()

  for i = 1, #items do
    list:insertRow
    {
      params = items[i]
    }
  end

  list:scrollToY({y = 0, time = 0 })
end

local function renderRow(event)
  local row = event.row
  local id = row.index
  local params = event.row.params

  local text = display.newText
  {
    parent = row,
    text = params[options.opt_attr],
    align = "left",
    x = 10,
    y = row.height / 2,
    fontSize = 15,
    font = native.systemFont,
    width = _AW - 20
  }
  text.anchorX = 0
  text:setFillColor(0,0,0)
end

local function touchRow(event)
  if not hiding and (event.phase == "tap" or event.phase == "release") then
    local row = event.row
    local id = row.index
    local params = event.row.params

    local value = params[options.val_attr]

    if value ~= options.value and options.onChanged then
      options.onChanged(value, params[options.opt_attr])
    end

    goBack()
  end
  return true
end

function scene:show(event)
  if event.phase == "will" then
    hiding = false
    options = event.params

    if event.params then
      navigationBar.title.text = event.params.title
      reloadItems(event.params.options, event.params.selected)
    else
      print("EEEAAEAEAEAEA NO PARAMS!")
    end
  end
end

function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title    = "",
    backBtn  = {
      title = "zpět",
      onTap = goBack
    },
  })
  group:insert(navigationBar)

  list = widget.newTableView
  {
    top = _T + navigationBar.height,
    left = _L,
    width = _AW,
    height = _AH - navigationBar.height,
    onRowRender = renderRow,
    onRowTouch  = touchRow
  }
  list.hideScrollBar = false
  group:insert(list)
end

function scene:hide(event)
  if event.phase == 'did' then
  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)
scene:addEventListener( "hide", scene)

return scene
