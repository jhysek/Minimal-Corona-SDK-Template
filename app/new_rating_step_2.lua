--------------------------------------------------------------------------------
local composer = require "composer"
local NavBar   = require "app.views.navBar"
local Form     = require "app.views.gridForm"
local Message  = require "app.views.message"
--------------------------------------------------------------------------------
local scene = composer.newScene()
local navigationBar
local form
local values
local back_params

local fields = {
  { name = "date", type = "date", label = T:t("new_rating_step_2.date") },
  { name = "hunter", label = T:t("new_rating_step_2.hunter"), validations = { presence = true } },
  { name = "place",  label = T:t("new_rating_step_2.place") },
  { name = "country",  label = T:t("new_rating_step_2.country")},
  { name = "submit", type = "submit", label = T:t("new_rating_step_2.submit") }
}

function scene:create(event)
  local group = self.view

  navigationBar = NavBar.create({
    title   = T:t("new_rating_step_1.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.new_rating_step_1", params = { without_reloading = true }},
  })
  group:insert(navigationBar)
end

function scene:show(event)
  local group = self.view
  if event.phase == "will" then

    if not (event.params and event.params.without_reloading) then
      if event.params then

        if event.params.back_params then
          navigationBar.title.text = T:t("new_rating_step_1.title") .. ": " .. T:t("title." .. event.params.code)
        end

        values = event.params.values
        back_params = event.params.back_params

        if form then
          form:removeSelf()
        end

        form = Form:new(group, fields, { height = _AH - 65 - banner_height })
        form.group.y = _T + 65
        form.onSubmit = function(values)
          native.setKeyboardFocus(nil)
          composer.gotoScene("app.new_rating_step_3", {
            effect = "slideLeft",
            params = {
              values = values,
              calculator = event.params.calculator,
              code = event.params.code,
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
