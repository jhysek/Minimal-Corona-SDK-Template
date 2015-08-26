--------------------------------------------------------------------------------
local widget   = require "widget"
local Color    = require "lib.Color"
local class    = require "lib.middleclass"
local MessageBox = require "app.views.message_box"
local Button  = require "app.views.button"
--------------------------------------------------------------------------------

local ProductPurchase = class("ProductPurchase", MessageBox)

function ProductPurchase:onCreate(group)
  self.onPurchase = function() print("NOT IMPLEMENTED") end

  self.title = display.newText
  {
    font = system.nativeFont,
    fontSize = 15,
    x = _L + 30,
    y = _H / 2 - self.bg.height / 2 + 5,
    align = "left",
    parent = group,
    text  = ""
  }
  self.title.anchorX = 0
  self.title:setFillColor(0,0,0)

  self.price = display.newText
  {
    font = system.nativeFontBold,
    fontSize = 17,
    x = _R - 30,
    y = _H / 2 - self.bg.height / 2 + 5,
    align = "right",
    parent = group,
    text  = ""
  }
  self.price.anchorX = 1
  Color.setFillHexColor(self.price, appconfig.main_color)

  self.description = display.newText
  {
    font = system.nativeFont,
    fontSize = 13,
    x = _W / 2,
    y = _H / 2 - self.bg.height / 2 + 30,
    align = "left",
    parent = group,
    width = _AW - 60,
    text  = ""
  }
  self.description:setFillColor(0,0,0, 0.7)

  buttonGroup = display.newGroup()
  buttonGroup.y = _H / 2 + 10
  group:insert(buttonGroup)
  local newRatingBtn = Button:new(buttonGroup, 0, T:t("product_purchase.purchase_btn"), "main", function() self.onPurchase(); return true; end, (_AW - 60) / 2, _L + _AW / 2 - (_AW - 60) / 4 - 5)
  local aboutAppBtn = Button:new(buttonGroup, 0, T:t("product_purchase.cancel_btn"), "gray", function() self:hide(); return true end, (_AW - 60) / 2, _L + _AW / 2 + (_AW - 60) / 4 + 5)

end

function ProductPurchase:onShow(data)
  self.title.text = data.title or ""
  self.price.text = data.price or ""
  self.description.text = data.description or ""
end

return ProductPurchase
