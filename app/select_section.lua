--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"
local store    = require "store"

local _        = require "lib.underscore"

local Message  = require "app.views.message"
local NavBar   = require "app.views.navBar"
local ListItem = require "app.views.listItem"
local Button   = require "app.views.button"
local ProductPurchase = require "app.views.product_purchase"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local navigationBar
local activateBtn
local list
local buttonGroup
local purchase_window
local products = {}

--------------------------------------------------------------------------------
local function doPurchase(product_id)
  ads.hide()
  purchase_window:hide()

  local purchase = Purchase:find({product = product_id})
  if not purchase then
    Purchase:insert({ product = product_id })
  end

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

local function productCallback( event )
  if event and event.products then
    print( "Showing valid products:", #event.products )
    for i = 1,#event.products do
      print(inspect(event.products[i]))
      products[event.products[i].productIdentifier] = event.products[i]
    end
    list:reloadData()
  else
    print("NO PRODUCT IN EVENT")
    print("EVENT: " .. inspect(event))
  end
end

local function loadProducts()
  if ( store.canLoadProducts ) then
    store.loadProducts( _.keys(products), productCallback)
  end
end

local function storeTransaction( event )
  local transaction = event.transaction
  if transaction.state == "purchased" then
    doPurchase(transaction.productIdentifier)

    Message.toast(T:t("product_purchase.purchased_msg"), { color = "#448800" })

    print("Transaction succuessful!")
    print("productIdentifier", transaction.productIdentifier)
    print("receipt", transaction.receipt)
    print("transactionIdentifier", transaction.identifier)
    print("date", transaction.date)

  elseif  transaction.state == "restored" then
    Message.toast(T:t("product_purchase.restored_msg"), { color = "#448800" })
    doPurchase(transaction.productIdentifier)
    print("Transaction restored (from previous session)")

  elseif transaction.state == "cancelled" then
    purchase_window:hide()
    Message.toast(T:t("product_purchase.cancelled_msg"), { color = "#881100" })
    print("User cancelled transaction")

  elseif transaction.state == "failed" then
    purchase_window:hide()
    Message.toast(T:t("product_purchase.failed_msg") .. " (" .. transaction.errorString .. ")", { color = "#881100" })
    print("Transaction failed, type:", transaction.errorType, transaction.errorString)

  else
    purchase_window:hide()
    print("unknown event")
  end

  store.finishTransaction( transaction )
end

local function tryPurchase(code)
  if (system.getInfo( "platfromName" ) == "Android") then
    code = code or appconfig.inapp_code_all.android
    store.purchase( code )
  else
    code = code or appconfig.inapp_code_all.ios
    store.purchase( { code })
  end
end

local function tryRestorePurchase()
  store.restore()
end
--------------------------------------------------------------------------------

local function onRowRender(event)
  local row = event.row

  local color = "#000000"
  local lock  = nil

  if not row.params.free and (not row.params.inapp_code or Purchase:count({ product = row.params.inapp_code }) == 0) then
    color = "#777777"
    lock  = "aktivovat"

    if products[row.params.inapp_code] and products[row.params.inapp_code].localizedPrice then
      lock = products[row.params.inapp_code].localizedPrice
    end
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

  if row.params.free or (row.params.inapp_code and Purchase:count({ product = row.params.inapp_code }) > 0) then
    composer.gotoScene("app.new_rating_step_1", { effect = "slideLeft", params = row.params })
  else

    local product = {}
    if products[row.params.inapp_code] and products[row.params.inapp_code].localizedPrice then
      product = products[row.params.inapp_code]
    end

    purchase_window:show({
      title = product.title or T:t("title." .. row.params.code),
      price = product.localizedPrice or row.params.inapp_price,
      description = product.description or row.params.inapp_description
    })

    purchase_window.onPurchase = function()
      tryPurchase(row.inapp_code)
    end
  end
end

local function activatedAll(form_definitions)
  local all = Purchase:count({ product = appconfig.inapp_code_all }) > 0
  local each = true

  for i = 1, #form_definitions.sections do
    if each then
      local definition = form_definitions.sections[i]
      if definition.inapp_code then
        each = Purchase:count({ product = definition.inapp_code }) > 0
      end
    end
  end

  return all or each
end


function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title   = T:t("select_section.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.dashboard" },
  })
  group:insert(navigationBar)

  local form_definitions = loadTable("config/form_definitions.json", system.ResourceDirectory) or {sections = {}}

  if not activatedAll(form_definitions) then
    local store_provider = "apple"
    if system.getInfo("platformName") == "Android" then
      print("ANDROID V3 IAP")
      store = require( "plugin.google.iap.v3" )
      store_provider = "google"
    end

    print("------------------------------ STORE INIT: " .. store_provider .. " -----------------")
    store.init(storeTransaction)
    print("------------------------------ STORE INIT DONE -------------------------------------")

    buttonGroup = display.newGroup()
    group:insert(buttonGroup)

    activateBtn = Button:new(
    buttonGroup,
    _B - 40,
    T:t("select_section.activate_all"),
    "main",
    function()
      purchase_window:show({ title = T:t("select_section.activate_all"), price = "100 Kč", description = T:t("select_section.activate_all_info") })
      purchase_window.onPurchase = tryPurchase
    end,
    (_AW - 60) / 2,
    _L + _AW / 2 - (_AW - 60) / 4 - 10
    )

    restoreBtn  = Button:new(buttonGroup, _B - 40, T:t("select_section.restore_purchases"), "gray", tryRestorePurchase, (_AW - 60) / 2, _L + _AW / 2 + (_AW - 60) / 4 + 10)

    buttonGroup.y = - banner_height
  end


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

  products = {}
  for i = 1, #form_definitions.sections do
    local definition = form_definitions.sections[i]
    if definition.inapp_code then
      products[definition.inapp_code] = { }
    end

    list:insertRow({
      rowHeight = 60,
      isCategory = false,
      rowColor = { 1, 1, 1 },
      lineColor = { 0.90, 0.90, 0.90 },
      params = definition
    })
  end

  timer.performWithDelay(50, loadProducts)

  list:scrollToY({ y = 0, time = 0 })

  purchase_window = ProductPurchase:new(group, { height = 120 })
end

scene:addEventListener( "create", scene)

return scene
