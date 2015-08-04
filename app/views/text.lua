local _ = require "lib.underscore"

local Text = {
  defaults = {
    fontSize = 15,
    font = "Helvetica Neue"
  }
}

function Text.createText(group, text, x, y, options)
  options = options or {}
  x = x or 0
  y = y or 0

  local defaults = _.extend({}, Text.defaults)
  local label_opts = _.extend(defaults, { text = text, parent = group })
  local label = display.newText(_.extend(label_opts, options))
  label.align = "center"
  label.x = x
  label.y = y

  label:setFillColor(0,0,0,1)

  return label
end

return Text
