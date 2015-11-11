--------------------------------------------------------------------------------
local composer = require "composer"
local NavBar   = require "app.views.navBar"
local Form     = require "app.views.gridForm"
local Message  = require "app.views.message"
local Head     = require "app.views.head"
--------------------------------------------------------------------------------
local scene = composer.newScene()
local navigationBar
local form
local values
local back_params

local fields = {
  { name = "age",     label = T:t("new_rating_step_2.age"),       validations = { numeric = true }},
  { name = "date",    label = T:t("new_rating_step_2.date"),      type = "date", value = "1.1.2001"},
  { name = "hunter",  label = T:t("new_rating_step_2.hunter"),    validations = { presence = true }},
  { name = "contact", label = T:t("new_rating_step_2.contact")},
  { name = "place",   label = T:t("new_rating_step_2.place")},
  { name = "country", label = T:t("new_rating_step_2.country")},
  { name = "photos" , label = T:t("new_rating_step_2.photos"),    type = "photos", height = 80, images = {}, count = 3},
  { name = "submit",  label = T:t("new_rating_step_2.submit"),    type = "submit"},
  { name = "footer",  label = T:t("new_rating_step_2.foot_text"), type = "section"}
}

function scene:redrawScene()
  local formValues = {}

  if form then
    for k,v in pairs(form:values()) do
      formValues[k] = v
    end
  end

  local group = self.view
  if sceneGroup then
    sceneGroup:removeSelf()
  end
  sceneGroup = display.newGroup()
  group:insert(sceneGroup)

  navigationBar = NavBar.create({
    title   = T:t("new_rating_step_1.title"),
    backBtn = {
      title = T:t("nav.back"),
      scene = "app.new_rating_step_1",
      params = { without_reloading = true }
    },
  })
  group:insert(navigationBar)

  if not (self.params and self.params.without_reloading) then
    if self.params then

      if self.params.back_params then
        navigationBar.title.text = T:t("new_rating_step_1.title") .. ": " .. T:t("title." .. self.params.code)
      end

      values = self.params.values
      back_params = self.params.back_params

      local head_height = Head.conditional_draw(sceneGroup,
                                            T:t("new_rating_step_2.head_text"),
                                            _T + 65)

      if form then
        form:removeSelf()
      end

      Rating.orderBy = 'created_at DESC'
      local lastRating = Rating:first()
      if lastRating then
        fields[2].default = lastRating.hunter
        fields[3].default = lastRating.place
        fields[4].default = lastRating.country
      end

      form = Form:new(group, fields, { height = _AH - 65 - banner_height - head_height })
      form:setValues(formValues)
      form.group.y = _T + 65
      form.onSubmit = function(values)
        values.photos = form.fields[7].images

        native.setKeyboardFocus(nil)
        composer.gotoScene("app.new_rating_step_3", {
          effect = "slideLeft",
          params = {
            values = values,
            calculator = self.params.calculator,
            code = self.params.code,
            back_params = self.params
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

function scene:show(event)
  local group = self.view
  if event.phase == "will" then
    if not event.params.without_reloading then
      self.params = event.params
    end
    self:redrawScene(event)
  end
end

scene:addEventListener( "show", scene)

return scene
