--------------------------------------------------------------------------------
local composer = require "composer"
local File     = require "lib.copy_file"
local NavBar   = require "app.views.navBar"
local Form     = require "app.views.gridForm"
local Message  = require "app.views.message"
local Head     = require "app.views.head"
--------------------------------------------------------------------------------

local scene = composer.newScene()
local navigationBar
local form
local formGroup
local sceneGroup

local function prepareFormDefinition(params)
  local code = params.code
  local fields = params.fields

  result = {}

  for i = 1, #fields do
    local field = fields[i]
    local field_code = (params.translation_code or params.code) .. ".fields." .. field.name

    field.label = T:t(field_code, "r")

    local help_data_dir = "help/"
    local path = system.pathForFile(help_data_dir .. field_code .. "T" .. language .. ".txt", system.ResourceDirectory )
    if path then
      local f = io.open( path )
      if f then
        field.help = field.help or {}
        field.help.text = f:read("*a")
        io.close(f)
      end
    end

    local img_filename = help_data_dir .. field_code .. "P.png"
    local img = display.newImage(img_filename)
    if not img then
      img_filename = help_data_dir .. field_code .. "P.jpg"
      img = display.newImage(img_filename)
    end

    if img then
      img:removeSelf()
      field.help = field.help or {}
      field.help.image = img_filename
    end

    if field.help then
      field.help.action = function()
        native.setKeyboardFocus(nil)
        composer.showOverlay("app.views.input_help_overlay", {
          isModal = true,
          effect = "fromBottom",
          params = {
            title = field.label,
            text  = field.help.text,
            image = field.help.image,
            dir   = system.ResourceDirectory
          }
        })
      end
    end

    if field.type ~= 'boolean' then
      field.validations = { presence = true, numeric = true }
      field.input_type = "decimal"
    end
    result[#result + 1] = field
  end

  result[#result + 1] = {
    type = "button",
    name = "submit",
    label = T:t("new_rating_step_1.submit"),
    onTap = function() form:submit() end,
  }

  result[#result + 1] = {
    name = "footer",
    label = T:t("new_rating_step_1.foot_text"),
    type = "section"
  }

  return result
end

function scene:redrawScene()
  local group = self.view
  local formValues = {}

  if form then
    for k,v in pairs(form:values()) do
      formValues[k] = v
    end
  end

  if sceneGroup then
    sceneGroup:removeSelf()
  end
  sceneGroup = display.newGroup()
  group:insert(sceneGroup)

  formGroup = display.newGroup()
  sceneGroup:insert(formGroup)

  navigationBar = NavBar.create({
    title   = T:t("new_rating_step_1.title"),
    backBtn = { title = T:t("nav.back"), scene = "app.select_section" },
  })
  sceneGroup:insert(navigationBar)

  if not (self.params and self.params.without_reloading) then
    if self.params and self.params.code then
      navigationBar.title.text = T:t("new_rating_step_1.title") .. ": " .. T:t("title." .. self.params.code)
    end
  end

  local head_height = Head.conditional_draw(sceneGroup,
                                            T:t("new_rating_step_1.head_text"),
                                            _T + 65)

  if not (self.params and self.params.without_reloading) then
    if form then
      form:removeSelf()
      form = nil
    end

    if self.params then
      form = Form:new(self.view, prepareFormDefinition(self.params), { height = _AH - 60 - banner_height - head_height,
                                                                       label_width = 0.8 })
      form:setValues(formValues)

      form.group.y = _T + 65 + head_height / 2
      form.onSubmit = function(values)
        local Calculator = require("app.calculators.calculator_" .. self.params.code)
        local calculator = Calculator:new(values)
        calculator:run()

        native.setKeyboardFocus(nil)
        composer.gotoScene("app.new_rating_step_2", {
          effect = "slideLeft",
          params = {
            calculator  = calculator,
            code        = self.params.code,
            back_params = self.params,
            clear       = true
          }
        })
      end

      form.onValidationFailed = function(errors)
        Message.toast(T:t("new_rating_step_1.validation_failed"))
      end
    end
  end
end


function scene:show(event)
  if event.phase == "will" then
    if not event.params.without_reloading then
      self.params = event.params
    end

    self:redrawScene()

    if not event.params.without_reloading then
      if event.params.clearForm then
        form:clear()
      end
    end
  end
end

scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)

return scene
