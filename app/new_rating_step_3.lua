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

local function save_trophy()
  local date_parts = values.date:split(".")
  local sort_date = string.format("%04d", date_parts[3]) ..
                    string.format("%02d", date_parts[2]) ..
                    string.format("%02d", date_parts[1])

  local rating_id = Rating:insert({
    date     = values.date,
    sort_date = sort_date,
    hunter   = values.hunter,
    animal   = code,
    rating   = calculator.soucet,
    medal    = calculator.medal,
    place    = values.place,
    country  = values.country,
    picture1 = values.photos[3],
    picture2 = values.photos[2],
    picture3 = values.photos[1],
    age      = values.age,
    positive = calculator.kladne,
    negative = calculator.zaporne,
    contact  = values.contact,
    created_at = os.time()
  })

  for key, val in pairs(calculator.inputs) do
    InputValue:insert({ key = key, value = val, rating_id = rating_id })
  end
  return rating_id
end


local function publish()
  native.showAlert(
    T:t("query.for.send1"),
    T:t("query.for.send2"),
    {
      T:t("query.for.send.yes"),
      T:t("query.for.send.delete"),
      T:t("query.for.send.no")
    },
    function(event)
      if event.action == "clicked" then
        -- klik na tlacitko odeslat - ulozime a odesleme
        if event.index == 1 then
          local rating_id = save_trophy()
          if appconfig.api_server_url then
            local rating = Rating:get(rating_id)
            Server.publishRating(rating, function()
              Runtime:dispatchEvent({name = "upload_finished", target = rating.id})
            end)
          end

        -- klik na tlacitko neodesilat - jen ulozime
        elseif event.index == 3 then
          save_trophy()
        end
      end
    end)

  composer.gotoScene("app.dashboard", {
    effect = "slideDown"
  })
end

local function prepareFormData(params)
  local calculator = params.calculator

  return {
    { name = "lov",   label = T:t('new_rating_step_2.date'), default = params.values.date },
    { name = "lovec", label = T:t('new_rating_step_2.hunter'), default = params.values.hunter },
    { name = "zver",  label = T:t('new_rating_step_3.trophy'), default = T:t("title." .. params.code) },
    { name = "space", type = "separator" },
    { name = "Kladné body",  label = T:t('new_rating_step_3.positive_points'), default = calculator.kladne },
    { name = "Záporné body", label = T:t('new_rating_step_3.negative_points'), default = calculator.zaporne },
    { name = "Celkem",  label = T:t('new_rating_step_3.total_points'), default = calculator.soucet },
    { name = "Medaile", label = T:t('dashboard.medal'), default = T:t("new_rating_step_3.medal." .. calculator.medal) },
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

function scene:show(event)
  if event.phase == "will" then
    self.params = event.params
    self:redrawScene()
  end
end

scene:addEventListener( "show", scene)

return scene
