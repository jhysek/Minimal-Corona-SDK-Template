--------------------------------------------------------------------------------
local composer = require "composer"
local widget   = require "widget"
local store    = require "store"

local _        = require "lib.underscore"

local Message  = require "app.views.message"
local NavBar   = require "app.views.navBar"
local ListItem = require "app.views.listItem"
local Button   = require "app.views.button"
local Head     = require "app.views.head"
local ProductPurchase = require "app.views.product_purchase"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local navigationBar
local activateBtn
local list
local buttonGroup
local purchase_window
local products = {}
local sceneGroup
local form_definitions

--------------------------------------------------------------------------------

local function activatedAll()
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

  navigationBar:toFront()
  if activatedAll() then
    buttonGroup.isVisible = false
  else
    list.height = list.height - 60
    buttonGroup:toFront()
    buttonGroup.y = 0
  end

  list.top = navigationBar.bottom
  list:reloadData()
  list:scrollToY({ y = 0 })

  return true
end

local function productCallback( event )
  if event and event.products then
    for i = 1,#event.products do
      local product = event.products[i]
      products[product.productIdentifier] = product

      if product.productIdentifier == appconfig.inapp_code_all and product.localizedPrice then
        activateBtn:setText(T:t("select_section.activate_all") .. " (" .. product.localizedPrice .. ")")
      end
    end
    list:reloadData()
  else
    print("NO PRODUCT IN EVENT")
    print("EVENT: " .. inspect(event))
  end
end

local function loadProducts()
  if (store.canLoadProducts) then
    local result = store.loadProducts( _.keys(products), productCallback)
  else
    Message.toast("store.calLoadProducts vraci false, neni podpora nacitani produktu?")
  end
end

local function storeTransaction( event )

  local transaction = event.transaction
  if transaction.state == "purchased" then
    doPurchase(transaction.productIdentifier)
    Message.toast(T:t("product_purchase.purchased_msg"), { color = "#448800" })

  elseif  transaction.state == "restored" then
    Message.toast(T:t("product_purchase.restored_msg"), { color = "#448800" })
    doPurchase(transaction.productIdentifier)

  elseif transaction.state == "cancelled" then
    purchase_window:hide()
    Message.toast(T:t("product_purchase.cancelled_msg"), { color = "#881100" })

  elseif transaction.state == "failed" then
    purchase_window:hide()
    Message.toast(T:t("product_purchase.failed_msg") .. " (" .. transaction.errorString .. ")", { color = "#881100" })

  else
    purchase_window:hide()
    print("unknown event")
  end

  store.finishTransaction( transaction )
end

local function tryPurchase(code)
  code = code or appconfig.inapp_code_all
  if system.getInfo("platformName") == "Android" then
    store.purchase( code )
  else
    store.purchase({code})
  end
end

local function tryRestorePurchase()
  store.restore()
end
--------------------------------------------------------------------------------

local function isProductActive(product)
  return product.free or
  (product.inapp_code and Purchase:count({ product = product.inapp_code }) > 0) or
  (Purchase:count({ product = appconfig.inapp_code_all }) > 0)
end

local function onRowRender(event)
  local row = event.row

  local color = "#000000"
  local lock  = nil

  if not isProductActive(row.params) then
    -- if not row.params.free and
    --   (not row.params.inapp_code or Purchase:count({ product = row.params.inapp_code }) == 0) and
    --   (Purchase:count({ product = appconfig.inapp_code_all })) then

    color = "#777777"
    lock  = T:t("select_section.activate")

    if products[row.params.inapp_code] and products[row.params.inapp_code].localizedPrice then
      lock = T:t("select_section.activate_for") .. " " .. products[row.params.inapp_code].localizedPrice
    end
  end

  local item = ListItem:new({
    width = _AW,
    height = 60,
    title  = T:t("title." .. row.params.code),
    titleColor = color,
    rightTextSize = 13,
    rightText = lock

  })
  row:insert(item.group)
end


local function onRowTouch(event)
  local row = event.row

  if event.phase == 'tap' or event.phase == 'release' then
    -- if row.params.free or
    --   (row.params.inapp_code and Purchase:count({ product = row.params.inapp_code }) > 0) then
    if isProductActive(row.params) then
      row.params.clearForm = true
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
        tryPurchase(row.params.inapp_code)
      end
    end
  end
end


function scene:redrawScene()
  local group = self.view

  if sceneGroup then
    sceneGroup:removeSelf()
  end
  sceneGroup = display.newGroup()
  group:insert(sceneGroup)

  navigationBar = NavBar.create({
    title   = T:t("select_section.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.dashboard" },
  })
  sceneGroup:insert(navigationBar)

  if not activatedAll() then
    if not store or not store.isActive then
      local store_provider = "apple"
      if system.getInfo("platformName") == "Android" then
        print("ANDROID V3 IAP")
        store = require( "plugin.google.iap.v3" )
        store_provider = "google"
      end

      print("------------------------------ STORE INIT: " .. store_provider .. " -----------------")
      store.init(store_provider, storeTransaction)
      print("------------------------------ STORE INIT DONE -------------------------------------")
    end

    buttonGroup = display.newGroup()
    sceneGroup:insert(buttonGroup)

    activateBtn = Button:new(
    buttonGroup,
    _B - 40,
    T:t("select_section.activate_all"),
    "main",
    function()
      if products[appconfig.inapp_code_all] then
        purchase_window:show({
          title = products[appconfig.inapp_code_all].title or "",
          price = products[appconfig.inapp_code_all].localizedPrice or "",
          description = products[appconfig.inapp_code_all].description or ""
        })
        purchase_window.onPurchase = function() tryPurchase(appconfig.inapp_code_all) end
      else
        Message.toast("Product is not available", { color = "#881100" })
      end
    end,
    (_AW - 60) / 2,
    _L + _AW / 2 - (_AW - 60) / 4 - 10
    )

    restoreBtn  = Button:new(buttonGroup, _B - 40, T:t("select_section.restore_purchases"), "gray", tryRestorePurchase, (_AW - 60) / 2, _L + _AW / 2 + (_AW - 60) / 4 + 10)
    buttonGroup.y = - banner_height
  end

  local head_height = Head.conditional_draw(sceneGroup,
  T:t("select_section.head_text"),
  _T + 65)

  list = widget.newTableView({
    x = _W / 2,
    top = navigationBar.bottom + 5 + head_height,
    width = _AW,
    height = _AH - navigationBar.height - 60 - banner_height - head_height,
    left = _L,
    onRowTouch = onRowTouch,
    onRowRender = onRowRender
  })
  sceneGroup:insert(list)

  products = {}
  products[appconfig.inapp_code_all] = {}

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

  local foot_text = T:t('select_section.foot_text')
  if foot_text and string.len(foot_text) > 0 then
    list:insertRow({
      rowHeight = 60,
      isCategory = true,
      rowColor = { 0.9, 0.9, 0.9 },
      lineColor = { 0.90, 0.90, 0.90 },
      params = foot_text
    })
  end

  if store.isActive then
    timer.performWithDelay(50, loadProducts)
  end

  list:scrollToY({ y = 0, time = 0 })

  purchase_window = ProductPurchase:new(sceneGroup, { height = 120 })
end

function scene:create(event)
  form_definitions = loadTable("config/form_definitions.json", system.ResourceDirectory) or {sections = {}}
end

function scene:show(event)
  if event.phase == 'will' then
    self:redrawScene(event)
  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene
