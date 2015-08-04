--------------------------------------------------------------------------------
local composer = require "composer"
local NavBar   = require "app.views.navBar"
local Form     = require "app.views.form"
local Message  = require "app.views.message"
--------------------------------------------------------------------------------
local scene = composer.newScene()
local navigationBar
local form

local function prepareFormDefinition(params)
  local code = params.code
  local fields = params.fields

  result = {}

  for i = 1, #fields do
    local field = fields[i]

    field.label = T:t(params.code .. ".fields." .. field.name)
    field.validations = { presence = true, numeric = true }
    result[#result + 1] = field
  end

  result[#result + 1] = {
    type = "button",
    name = "submit",
    label = T:t("new_rating_step_1.submit"),
    onTap = function() form:submit() end
  }

  return result
end

function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title   = T:t("new_rating_step_1.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.select_section" },
  })
  group:insert(navigationBar)
end

function scene:show(event)
  local group = self.view

  if event.phase == "will" then

    if not (event.params and event.params.without_reloading) then
      if event.params and event.params.code then
        navigationBar.title.text = T:t("new_rating_step_1.title") .. ": " .. T:t("title." .. event.params.code)
      end

      if form then
        form:removeSelf()
      end

      if event.params then
        form = Form:new(group, prepareFormDefinition(event.params), { height = _AH - navigationBar.height - banner_height })
        form.group.y = _T + 65

        form.onSubmit = function(values)
          print("SUBMITTED: " .. inspect(values))

          local Calculator = require("app.calculators.calculator_" .. event.params.code)
          local calculator = Calculator:new(values)
          calculator:run()

          native.setKeyboardFocus(nil)
          composer.gotoScene("app.new_rating_step_2", {
            effect = "slideLeft",
            params = {
              calculator = calculator,
              code   = event.params.code,
              back_params = event.params
            }
          })
        end

        form.onValidationFailed = function(errors)
          Message.toast(T:t("new_rating_step_1.validation_failed"))
        end

        group:insert(form.group)
      end
    end
  end
end


scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene
