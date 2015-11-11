--------------------------------------------------------------------------------
local composer = require "composer"
local Xml      = require "app.services.xml_generator"
local Server   = require "app.services.server"
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
local backBtn
local sceneGroup

local function publish()
  if appconfig.api_server_url then

    local xml = Xml.generate(code, calculator, values)
    print(inspect(xml))
    timer.performWithDelay(20, function()
--      Server.publish(xml)
    end)
  end

  composer.gotoScene("app.dashboard", {
    effect = "slideDown"
  })
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


function scene:redrawScene()
  group = scene.view
  if sceneGroup then
    sceneGroup:removeSelf()
  end
  sceneGroup = display.newGroup()
  group:insert(sceneGroup)

  navigationBar = NavBar.create({
    title   = T:t("new_rating_step_1.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.new_rating_step_2", params = { without_reloading = true }},
  })

  sceneGroup:insert(navigationBar)

  if self.params then
    if self.params.back_params then
      navigationBar.title.text = T:t("new_rating_step_1.title") .. ": " .. T:t("title." .. self.params.code)
    end

    code        = self.params.code
    values      = self.params.values
    calculator  = self.params.calculator
    back_params = self.params.back_params

    Rating:insert({
      date = values.date,
      hunter = values.hunter,
      animal = code,
      rating = calculator.soucet,
      medal = calculator.medal,
      place = values.place,
      country = values.country,
      picture1 = values.photos[3],
      picture2 = values.photos[2],
      picture3 = values.photos[1],
      created_at = os.time()
    })

    if form then
      form:removeSelf()
    end

    if self.params then
      form = Form:new(sceneGroup, prepareFormData(self.params), {
        readOnly = true,
        height = _AH - 65 - 65 - banner_height,
        value_align = 'right',
        value_padding_right = 20,
        value_font_size  = 15
      })
      form.group.y = _T + 65
      sceneGroup:insert(form.group)

      if self.params.calculator and self.params.calculator.medal ~= "none" then
      end
    end
  end

  if appconfig.api_server_url then
    Button:new(sceneGroup, _B - 40 - banner_height, T:t("new_rating_step_3.publish"), "main", publish, _AW - 40)
  else
    Button:new(sceneGroup, _B - 40 - banner_height, T:t("new_rating_step_3.back"), "main", publish, _AW - 40)
  end
end


function scene:create(event)
  local group = self.view

end


function scene:show(event)
  if event.phase == "will" then
    self.params = event.params
    self:redrawScene()
  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene
