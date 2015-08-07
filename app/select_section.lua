--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"
-- local store    = require "store"

local NavBar   = require "app.views.navBar"
local ListItem = require "app.views.listItem"
local Button   = require "app.views.button"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local navigationBar
local activateBtn
local list
local buttonGroup

--------------------------------------------------------------------------------
local function doPurchase()
  ads.hide()

  Setting:delete()
  Setting:insert({ premium = 1 })

  premium = true
  banner_height = 0
  list.height = _AH - navigationBar.height
  list.top = navigationBar.bottom
  list:reloadData()
  list:scrollToY({ y = 0 })

  navigationBar:toFront()
  buttonGroup.isVisible = false

  return true
end

local function storeTransaction( event )
  local transaction = event.transaction
  if transaction.state == "purchased" then
    doPurchase()
    print("Transaction succuessful!")
    print("productIdentifier", transaction.productIdentifier)
    print("receipt", transaction.receipt)
    print("transactionIdentifier", transaction.identifier)
    print("date", transaction.date)

  elseif  transaction.state == "restored" then
    doPurchase()
    print("Transaction restored (from previous session)")

  elseif transaction.state == "cancelled" then
    print("User cancelled transaction")

  elseif transaction.state == "failed" then
    print("Transaction failed, type:", transaction.errorType, transaction.errorString)

  else
    print("unknown event")
  end

  -- store.finishTransaction( transaction )
end

local function tryPurchase()
  if (system.getInfo( "platfromName" ) == "Android") then
    -- store.purchase( { appconfig.inapp_code.android })
  else
    -- store.purchase( { appconfig.inapp_code.ios })
  end
end

local function tryRestorePurchase()
  -- store.restore()
end
--------------------------------------------------------------------------------



local function onRowRender(event)
  local row = event.row

  local color = "#000000"
  local lock  = nil
  if not row.params.free and not premium then
    color = "#777777"
    lock  = "aktivovat"
  end

  local item = ListItem:new({
    width = _AW,
    height = 60,
    title  = T:t("title." .. row.params.code),
    titleColor = color,
    rightText = lock

  })
  row:insert(item.group)
end

local function onRowTouch(event)
  local row = event.row

  if row.params.free or premium then
    composer.gotoScene("app.new_rating_step_1", { effect = "slideLeft", params = row.params })
  else
    tryPurchase()
  end
end

function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title   = T:t("select_section.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.dashboard" },
  })
  group:insert(navigationBar)

  if not premium then
   -- store.init(storeTransaction)

    buttonGroup = display.newGroup()
    group:insert(buttonGroup)

    activateBtn = Button:new(buttonGroup, _B - 40, T:t("select_section.activate_all"), "main", doPurchase, (_AW - 60) / 2, _L + _AW / 2 - (_AW - 60) / 4 - 10)
    restoreBtn  = Button:new(buttonGroup, _B - 40, T:t("select_section.restore_purchases"), "gray", tryRestorePurchase, (_AW - 60) / 2, _L + _AW / 2 + (_AW - 60) / 4 + 10)

    buttonGroup.y = - banner_height
  end

  local form_definitions = loadTable("config/form_definitions.json", system.ResourceDirectory) or {sections = {}}

  list = widget.newTableView({
    x = _W / 2,
    top = navigationBar.bottom,
    width = _AW,
    height = _AH - navigationBar.height - 60 - banner_height,
    left = _L,
    onRowTouch = onRowTouch,
    onRowRender = onRowRender
  })
  group:insert(list)

  for i = 1, #form_definitions.sections do
    local definition = form_definitions.sections[i]
    list:insertRow({
      rowHeight = 60,
      isCategory = false,
      rowColor = { 1, 1, 1 },
      lineColor = { 0.90, 0.90, 0.90 },
      params = definition
    })
  end

  list:scrollToY({ y = 0, time = 0 })
end

scene:addEventListener( "create", scene)

return scene
