--------------------------------------------------------------------------------
local composer = require "composer"
local NavBar   = require "app.views.navBar"
local Message  = require "app.views.message"
local Form     = require "app.views.form"
local Button   = require "app.views.button"
--------------------------------------------------------------------------------
local scene = composer.newScene()
local navigationBar
local form
local values
local back_params
local calculator
local code

local function publish()

  Rating:insert({
    date = values.date,
    hunter = values.hunter,
    animal = code,
    rating = calculator.soucet,
    medal = calculator.medal
  })

  composer.gotoScene("app.dashboard", {
    effect = "slideDown"
  })
end

function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title   = T:t("new_rating_step_1.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.new_rating_step_2", params = { without_reloading = true }},
  })
  group:insert(navigationBar)

  local publishBtn = Button:new(group, _B - 40 - banner_height, T:t("new_rating_step_3.publish"), "main", publish, _AW - 40)
end

local function prepareFormData(params)
  local calculator = params.calculator

  return {
    { name = "lov", label = "Lov", default = params.values.date },
    { name = "lovec", label = "Lovec", default = params.values.hunter },
    { name = "zver", label = "Zvěř", default = T:t("title." .. params.code) },
    { name = "space", type = "separator" },
    { name = "Kladné body", label = "Kladné body", default = calculator.kladne },
    { name = "Záporné body", label = "Záporné body", default = calculator.zaporne },
    { name = "Celkem", label = "Celkem", default = calculator.soucet },
    { name = "Medaile", label = "Medaile", default = T:t("new_rating_step_3.medal." .. calculator.medal) },
    { name = "medal", type = "image", filename = "assets/" .. calculator.medal .. ".png", height = 80, lineColor = {1,1,1} }
  }
end

function scene:show(event)
  local group = self.view
  if event.phase == "will" then
    if event.params then
      if event.params.back_params then
        navigationBar.title.text = T:t("new_rating_step_1.title") .. ": " .. T:t("title." .. event.params.code)
      end

      code = event.params.code
      values = event.params.values
      calculator = event.params.calculator
      back_params = event.params.back_params

      if form then
        form:removeSelf()
      end

      if event.params then
        form = Form:new(group, prepareFormData(event.params), {
          readOnly = true,
          height = _AH - 65 - 65 - banner_height,
          value_align = 'right',
          value_padding_right = 20,
          value_font_size  = 15
        })
        form.group.y = _T + 65
        group:insert(form.group)

        if event.params.calculator and event.params.calculator.medal ~= "none" then
        end
      end
    end
  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene
