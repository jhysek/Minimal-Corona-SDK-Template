local widget     = require "widget"
local composer   = require "composer"
local class      = require "lib.middleclass"
local MessageBox = require "app.views.message_box"
local Button     = require "app.views.button"

local LanguageSelectBox = class("LanguageSelectBox", MessageBox)

function LanguageSelectBox:selectLanguage(code)
  setLanguage(code)
  local current_scene = composer.getScene(composer.getSceneName("current"))
  current_scene:redrawScene()
  self:hide()
end

function LanguageSelectBox:redrawButtons()
  if self.buttonGroup then
    self.buttonGroup:removeSelf()
  end
  self.buttonGroup = display.newGroup()
  self.detailGroup:insert(self.buttonGroup)

  local offsetY = self.bg.y - self.bg.height / 2 + 80
  for code, name in pairs(availableLanguages()) do
    Button:new(
      self.buttonGroup,
      offsetY,
      name,
      code == language and "main" or "gray",
      function() self:selectLanguage(code) end,
      self.bg.width - 40,
      nil,
      {
        fontSize = 15
      }
      )
    offsetY = offsetY + 50
  end
end

function LanguageSelectBox:onCreate()
  self:newText(T:t('language_select.title'),
               _W / 2,
               self.bg.y - self.bg.height / 2 + 25,
               {
                fontSize = 17
               })
end

function LanguageSelectBox:onShow()
  self:redrawButtons()
end


return LanguageSelectBox
